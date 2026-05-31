import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  server: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: true,
    hmr: {
      // HMR through Nginx HTTPS proxy
      // Client will automatically use the page host (localhost or external IP)
      protocol: 'wss',
      clientPort: 8443
    }
  },
  appType: 'spa',  // Enable SPA fallback - all routes serve index.html
  optimizeDeps: {
    include: [
      '@babylonjs/core',
      '@babylonjs/inspector',
      '@babylonjs/addons',
      '@babylonjs/materials'
    ]
  }
});