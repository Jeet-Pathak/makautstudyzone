/**
 * Cloudflare Pages Function: /api/pdf-proxy
 *
 * Proxies Google Drive PDFs (and any HTTPS URL) to avoid CORS restrictions.
 * Converted from Vercel serverless handler to Cloudflare Workers onRequest style.
 *
 * Query params:
 *   ?id=<google-drive-file-id>   -- fetch by Drive file ID
 *   ?url=<encoded-url>           -- fetch by arbitrary HTTPS URL (Drive link or direct)
 */

const USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

async function fetchWithRetry(url, options = {}, retries = 4, backoff = 1500) {
  for (let i = 0; i < retries; i++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 12000);
    try {
      const response = await fetch(url, { ...options, signal: controller.signal });
      clearTimeout(timeoutId);

      if (response.status === 503 && i < retries - 1) {
        console.warn(`Google Drive 503, retrying in ${backoff}ms (attempt ${i + 1}/${retries})...`);
        await sleep(backoff);
        backoff *= 2;
        continue;
      }
      return response;
    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        console.warn(`Fetch timed out (attempt ${i + 1}/${retries})`);
      }
      if (i === retries - 1) throw err;
      await sleep(backoff);
      backoff *= 2;
    }
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
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
    /^([a-zA-Z0-9_-]{20,})$/,
  ];
  for (const p of patterns) {
    const m = str.match(p);
    if (m && m[1]) return m[1];
  }
  return null;
}

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
  'Access-Control-Allow-Headers': 'Range, Content-Type',
  'Access-Control-Expose-Headers': 'Content-Range, Content-Length, Accept-Ranges',
};

export async function onRequest({ request }) {
  // Handle CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: CORS_HEADERS });
  }

  const reqUrl = new URL(request.url);
  const id = reqUrl.searchParams.get('id');
  const urlParam = reqUrl.searchParams.get('url');
  const fileId = id || (urlParam ? extractDriveId(urlParam) : null);

  let targetUrl = '';

  if (fileId) {
    targetUrl = `https://drive.usercontent.google.com/download?id=${fileId}&export=download`;
  } else if (urlParam && (urlParam.startsWith('http://') || urlParam.startsWith('https://'))) {
    targetUrl = urlParam;
  } else {
    return new Response('Missing file id or valid url', {
      status: 400,
      headers: CORS_HEADERS,
    });
  }

  const headers = { 'User-Agent': USER_AGENT };

  // Forward Range header for partial content requests (PDF viewer seeking)
  const rangeHeader = request.headers.get('Range');
  if (rangeHeader) headers['Range'] = rangeHeader;

  try {
    let response = await fetchWithRetry(targetUrl, { headers });

    const contentType = response.headers.get('content-type') || '';

    // Google Drive may return an HTML consent/confirm page -- handle it
    if (contentType.includes('text/html') && fileId) {
      const html = await response.text();
      const match =
        html.match(/confirm=([a-zA-Z0-9_-]+)/) ||
        html.match(/name="confirm"\s+value="([^"]+)"/);

      if (match) {
        const confirmUrl = `https://drive.usercontent.google.com/download?confirm=${match[1]}&id=${fileId}&export=download`;
        response = await fetchWithRetry(confirmUrl, { headers });
      } else {
        const fallbackUrl = `https://drive.google.com/uc?export=download&id=${fileId}&confirm=t`;
        response = await fetchWithRetry(fallbackUrl, { headers });
      }
    }

    const buffer = await response.arrayBuffer();
    const bytes = new Uint8Array(buffer);

    // Validate PDF magic bytes (%PDF = 0x25 0x50 0x44 0x46)
    if (
      bytes.length < 4 ||
      bytes[0] !== 0x25 ||
      bytes[1] !== 0x50 ||
      bytes[2] !== 0x44 ||
      bytes[3] !== 0x46
    ) {
      console.warn(
        'Response does not start with %PDF. First 20 bytes:',
        Array.from(bytes.slice(0, 20))
      );
      return new Response('Google Drive did not return a valid PDF file.', {
        status: 502,
        headers: CORS_HEADERS,
      });
    }

    return new Response(buffer, {
      status: 200,
      headers: {
        ...CORS_HEADERS,
        'Content-Type': 'application/pdf',
        'Content-Length': String(buffer.byteLength),
        'Content-Disposition': 'inline',
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=86400, s-maxage=86400, stale-while-revalidate=604800',
      },
    });
  } catch (error) {
    console.error('PDF Proxy Error:', error);
    const isTimeout = error.name === 'AbortError';
    return new Response(
      isTimeout
        ? 'Request to Google Drive timed out. Please try again.'
        : `Internal Server Error: ${error.message}`,
      {
        status: isTimeout ? 504 : 500,
        headers: CORS_HEADERS,
      }
    );
  }
}
