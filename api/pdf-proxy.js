async function fetchWithRetry(url, options = {}, retries = 4, backoff = 1500) {
  for (let i = 0; i < retries; i++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 12000);

      const response = await fetch(url, {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      if (response.status === 503 && i < retries - 1) {
        console.warn(`Google Drive returned 503, retrying in ${backoff}ms (attempt ${i + 1}/${retries})...`);
        await new Promise(resolve => setTimeout(resolve, backoff));
        backoff *= 2;
        continue;
      }
      return response;
    } catch (err) {
      if (err.name === 'AbortError') {
        console.warn(`Fetch timed out for attempt ${i + 1}/${retries}`);
      }
      if (i === retries - 1) throw err;
      await new Promise(resolve => setTimeout(resolve, backoff));
      backoff *= 2;
    }
  }
}

function extractDriveId(link) {
  if (!link || typeof link !== 'string') return null;
  const str = link.trim();
  const patterns = [
    /\/file\/d\/([a-zA-Z0-9_-]+)/i,
    /\/document\/d\/([a-zA-Z0-9_-]+)/i,
    /\/presentation\/d\/([a-zA-Z0-9_-]+)/i,
    /\/spreadsheets\/d\/([a-zA-Z0-9_-]+)/i,
    /\/d\/([a-zA-Z0-9_-]+)/i,
    /[?&]id=([a-zA-Z0-9_-]+)/i,
    /\/uc\?id=([a-zA-Z0-9_-]+)/i,
    /^([a-zA-Z0-9_-]{20,})$/
  ];
  for (const p of patterns) {
    const m = str.match(p);
    if (m && m[1]) return m[1];
  }
  return null;
}

export default async function handler(req, res) {
  // CORS Preflight & headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Range, Content-Type');
  res.setHeader('Access-Control-Expose-Headers', 'Content-Range, Content-Length, Accept-Ranges');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const { id, url } = req.query || {};
  let targetUrl = '';
  const fileId = id || (url ? extractDriveId(url) : null);

  if (fileId) {
    targetUrl = `https://drive.usercontent.google.com/download?id=${fileId}&export=download`;
  } else if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
    targetUrl = url;
  } else {
    return res.status(400).send('Missing file id or valid url');
  }

  const headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
  };

  if (req.headers && req.headers.range) {
    headers['Range'] = req.headers.range;
  }

  try {
    let response = await fetchWithRetry(targetUrl, { headers });

    const contentType = response.headers.get('content-type') || '';
    if (contentType.includes('text/html') && fileId) {
      const html = await response.text();
      const match = html.match(/confirm=([a-zA-Z0-9_-]+)/) || html.match(/name="confirm"\s+value="([^"]+)"/);
      if (match) {
        const confirmToken = match[1];
        const confirmUrl = `https://drive.usercontent.google.com/download?confirm=${confirmToken}&id=${fileId}&export=download`;
        response = await fetchWithRetry(confirmUrl, { headers });
      } else {
        const fallbackUrl = `https://drive.google.com/uc?export=download&id=${fileId}&confirm=t`;
        response = await fetchWithRetry(fallbackUrl, { headers });
      }
    }

    const buffer = await response.arrayBuffer();
    const bytes = new Uint8Array(buffer);

    // Validate PDF header (%PDF)
    if (bytes.length < 4 || bytes[0] !== 0x25 || bytes[1] !== 0x50 || bytes[2] !== 0x44 || bytes[3] !== 0x46) {
      console.warn('Response does not start with %PDF header. First 20 bytes:', Array.from(bytes.slice(0, 20)));
      return res.status(502).send('Google Drive did not return a valid PDF file.');
    }

    res.setHeader('Accept-Ranges', 'bytes');
    res.setHeader('Cache-Control', 'public, max-age=86400, s-maxage=86400, stale-while-revalidate=604800');
    res.setHeader('Content-Disposition', 'inline');
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Length', buffer.byteLength);

    return res.status(200).send(Buffer.from(buffer));
  } catch (error) {
    console.error('PDF Proxy Error:', error);
    const status = error.name === 'AbortError' ? 504 : 500;
    return res.status(status).send(error.name === 'AbortError' ? 'Request to Google Drive timed out. Please try again.' : `Internal Server Error: ${error.message}`);
  }
}
