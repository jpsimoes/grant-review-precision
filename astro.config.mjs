import { defineConfig } from 'astro/config';

export default defineConfig({
  // Custom domain (registered at Cloudflare, served via Netlify external DNS).
  // Drives canonical, Open Graph, and RSS absolute URLs.
  site: 'https://jorgepianosimoes.com',
});
