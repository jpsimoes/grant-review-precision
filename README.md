# Jorge Piano Simões — Personal Website

Single-page personal site for Jorge Piano Simões — Assistant Professor in Health
Psychology, AI & Technology at the University of Twente.

## Stack

- [Astro](https://astro.build) — static site, zero client JS except scroll reveals
- Hand-written CSS design system (`src/styles/global.css`) — warm editorial:
  Newsreader serif, warm paper, deep green accent
- Essays as markdown in `src/content/writing/`
- Deployed on Netlify (`npm run build` → `dist/`)

## Development

```bash
npm install
npm run dev
```

## Adding an essay

Drop a markdown file in `src/content/writing/` with `title`, `date`, and
`description` frontmatter. It appears on the landing page and in the RSS feed.

## License

Content: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) unless a page specifies another license.
