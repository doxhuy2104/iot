import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'https://smart-watering-backend.onrender.com';

// API Proxy - must be before static files
app.use('/api', createProxyMiddleware({
  target: BACKEND_URL,
  changeOrigin: true,
  secure: true,
  headers: {
    // Set origin to backend's own origin to bypass CORS check
    'Origin': BACKEND_URL,
  },
  onProxyReq: (proxyReq, req, res) => {
    // Remove headers that trigger CORS checks
    proxyReq.removeHeader('origin');
    proxyReq.removeHeader('referer');
    // Set host to target host
    proxyReq.setHeader('Host', new URL(BACKEND_URL).host);
  },
  onProxyRes: (proxyRes, req, res) => {
    // Remove CORS headers from response since we're proxying
    delete proxyRes.headers['access-control-allow-origin'];
    delete proxyRes.headers['access-control-allow-credentials'];
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(502).json({ 
      error: 'Backend service unavailable',
      message: 'Unable to connect to the backend server. Please try again later.'
    });
  }
}));

// Serve static files from dist folder
app.use(express.static(path.join(__dirname, 'dist')));

// Handle SPA routing - serve index.html for all non-API routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Backend URL: ${BACKEND_URL}`);
});
