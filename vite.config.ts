import {defineConfig} from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
    plugins: [react(), tailwindcss()],
    clearScreen: false,
    server: {
        host: true,
        port: 3000,
        strictPort: true,
        hmr: {
            protocol: "ws",
            host: "localhost",
            port: 3000,
            clientPort: 3000,
            overlay: true
        },
        "proxy": {
            "/api": {
                target: "http://localhost:8000",
                changeOrigin: true,
                secure: false
            }
        },
        watch: {
            ignored: ["**/src-*/**", "vendor/**", ".bruno/**", ".docker/**", "composer.*", "**/.git/**", "**/node_modules/**", "dist/**", "**/*.log", ".env*", ".htaccess", "nginx.conf", "set_root.php", "scripts/**", "Justfile", "**/*.md"]
        }
    },
    build: {
        outDir: "dist/"
    }
});