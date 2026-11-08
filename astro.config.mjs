import { defineConfig } from 'astro/config';
import { unified } from '@astrojs/markdown-remark';
import studyDisplays from './src/markdown/study-displays.mjs';

export default defineConfig({
  // Custom domain (registered at Cloudflare, served via Netlify external DNS).
  // Drives canonical, Open Graph, and RSS absolute URLs.
  site: 'https://jorgepianosimoes.com',
  markdown: { processor: unified({ rehypePlugins: [studyDisplays] }) },
});
