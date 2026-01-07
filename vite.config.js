import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true, // Allow external connections
    allowedHosts: ['.ngrok-free.dev', '.ngrok.io', 'localhost'], // Allow ngrok tunnels
    proxy: {
      '/api': {
        target: 'https://smart-watering-backend.onrender.com',
        changeOrigin: true,
        secure: true,
        configure: (proxy, _options) => {
          proxy.on('proxyReq', (proxyReq, req, _res) => {
            // Remove Origin header to avoid CORS issues
            proxyReq.removeHeader('origin');
          });
        },
      },
    },
  },

})
