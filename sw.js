// MaestroAC Service Worker v2.0
// Auto-invalidates cache on every new deploy
const CACHE_VERSION = 'maestroac-v2025-0208-1530';
const CACHE_NAME = CACHE_VERSION;

// Files to cache
const PRECACHE_FILES = [
  '/',
  '/index.html',
  '/logo.png'
];

// Install: cache core files
self.addEventListener('install', event => {
  console.log('[SW] Installing version:', CACHE_VERSION);
  // Skip waiting to activate immediately
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll(PRECACHE_FILES).catch(err => {
        console.log('[SW] Precache partial failure:', err);
      });
    })
  );
});

// Activate: delete ALL old caches
self.addEventListener('activate', event => {
  console.log('[SW] Activating version:', CACHE_VERSION);
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name !== CACHE_NAME)
          .map(name => {
            console.log('[SW] Deleting old cache:', name);
            return caches.delete(name);
          })
      );
    }).then(() => {
      // Take control of all pages immediately
      return self.clients.claim();
    }).then(() => {
      // Notify all tabs to reload
      return self.clients.matchAll({ type: 'window' }).then(clients => {
        clients.forEach(client => {
          client.postMessage({ type: 'SW_UPDATED', version: CACHE_VERSION });
        });
      });
    })
  );
});

// Fetch: Network-first strategy for HTML, cache-first for assets
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  
  // Skip non-GET requests and external URLs
  if (event.request.method !== 'GET') return;
  if (!url.origin.includes(self.location.origin)) return;
  
  // HTML files: ALWAYS network first (ensures latest version)
  if (event.request.headers.get('accept')?.includes('text/html') || 
      url.pathname === '/' || 
      url.pathname.endsWith('.html')) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          // Cache the fresh response
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
          return response;
        })
        .catch(() => {
          // Offline fallback
          return caches.match(event.request);
        })
    );
    return;
  }
  
  // Other assets (images, CSS, JS): cache first, then network
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        return response;
      });
    })
  );
});

// Listen for skip waiting message from the page
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
