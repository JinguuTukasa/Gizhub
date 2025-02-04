import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0", // すべてのIPからアクセス可能にする
    port: 5173, // Docker内で起動するポート
    watch: {
      usePolling: true, // ファイル変更を監視
    },
    hmr: {
      clientPort: 5173, // HMR (ホットリロード) のポート
    },
  }
})
