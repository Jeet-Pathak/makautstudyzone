const CACHE_NAME = 'msz-cache-v1';

self.addEventListener('install', (event) => {
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(clients.claim());
});

self.addEventListener('fetch', (event) => {
    // Basic pass-through fetch handler required for PWA installability
    event.respondWith(
        fetch(event.request).catch(() => {
            return new Response('Offline', { status: 503, statusText: 'Offline' });
        })
    );
});
