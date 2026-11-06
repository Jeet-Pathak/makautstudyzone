import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [
    {
      name: 'pdf-proxy-middleware',
      configureServer(server) {
        async function fetchWithRetry(url, options = {}, retries = 4, backoff = 1500) {
          for (let i = 0; i < retries; i++) {
            try {
              const controller = new AbortController();
              const timeoutId = setTimeout(() => controller.abort(), 12000);
              const response = await fetch(url, { ...options, signal: controller.signal });
              clearTimeout(timeoutId);
              if (response.status === 503 && i < retries - 1) {
                console.warn(`Google Drive returned 503, retrying in ${backoff}ms (attempt ${i + 1}/${retries})...`);
                await new Promise(resolve => setTimeout(resolve, backoff));
                backoff *= 2;
                continue;
              }
              return response;
            } catch (err) {
              if (err.name === 'AbortError') console.warn(`Fetch timed out for attempt ${i + 1}/${retries}`);
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

        server.middlewares.use(async (req, res, next) => {
          const urlObj = new URL(req.url, 'http://localhost');
          if (urlObj.pathname === '/api/pdf-proxy') {
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
            res.setHeader('Access-Control-Allow-Headers', 'Range, Content-Type');
            res.setHeader('Access-Control-Expose-Headers', 'Content-Range, Content-Length, Accept-Ranges');

            if (req.method === 'OPTIONS') {
              res.statusCode = 200;
              return res.end();
            }

            const id = urlObj.searchParams.get('id');
            const targetParamUrl = urlObj.searchParams.get('url');
            const fileId = id || (targetParamUrl ? extractDriveId(targetParamUrl) : null);
            let targetUrl = '';

            if (fileId) {
              targetUrl = `https://drive.usercontent.google.com/download?id=${fileId}&export=download`;
            } else if (targetParamUrl && (targetParamUrl.startsWith('http://') || targetParamUrl.startsWith('https://'))) {
              targetUrl = targetParamUrl;
            } else {
              res.statusCode = 400;
              return res.end('Missing file id or valid url');
            }

            const headers = {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            };
            if (req.headers.range) headers['Range'] = req.headers.range;

            try {
              let response = await fetchWithRetry(targetUrl, { headers });
              const contentType = response.headers.get('content-type') || '';
              if (contentType.includes('text/html') && fileId) {
                const html = await response.text();
                const match = html.match(/confirm=([a-zA-Z0-9_-]+)/) || html.match(/name="confirm"\s+value="([^"]+)"/);
                if (match) {
                  response = await fetchWithRetry(`https://drive.usercontent.google.com/download?confirm=${match[1]}&id=${fileId}&export=download`, { headers });
                } else {
                  const fallbackUrl = `https://drive.google.com/uc?export=download&id=${fileId}&confirm=t`;
                  response = await fetchWithRetry(fallbackUrl, { headers });
                }
              }

              const buffer = await response.arrayBuffer();
              const bytes = new Uint8Array(buffer);
              if (bytes.length < 4 || bytes[0] !== 0x25 || bytes[1] !== 0x50 || bytes[2] !== 0x44 || bytes[3] !== 0x46) {
                res.statusCode = 502;
                return res.end('Source did not return a valid PDF file.');
              }

              res.setHeader('Accept-Ranges', 'bytes');
              res.setHeader('Content-Type', 'application/pdf');
              res.setHeader('Content-Length', buffer.byteLength);
              res.setHeader('Content-Disposition', 'inline');
              res.statusCode = 200;
              return res.end(Buffer.from(buffer));
            } catch (error) {
              console.error('Vite PDF Proxy Error:', error);
              res.statusCode = error.name === 'AbortError' ? 504 : 500;
              return res.end(error.name === 'AbortError' ? 'Request to PDF source timed out.' : `Internal Server Error: ${error.message}`);
            }
          }
          next();
        });
      }
    }
  ],
  build: {
    target: 'esnext',
    outDir: 'dist',
    sourcemap: false,
    minify: false,
    rollupOptions: {
      input: 'index.html'
    }
  }
});
