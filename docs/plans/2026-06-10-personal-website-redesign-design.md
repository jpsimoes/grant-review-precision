# Personal Website Redesign — Design

**Date:** 2026-06-10
**Status:** Validated with Jorge, ready for implementation planning

## Goal

Replace the current Quarto/Bootstrap site with a sleek, modern personal site that positions Jorge as a professional brand at the intersection of health psychology and AI — for talks, collaborations, media, and industry visibility. Less CV, more "this is who I am and what I think."

## Key decisions

| Decision | Choice | Rationale |
|---|---|---|
| Purpose | Professional brand | Chosen over academic showcase / writing-first / calling card |
| Visual direction | Warm editorial | Serif-led, warm paper, counters the generic "AI guy" dark-techy look; fits a health psychologist |
| Accent color | Deep forest green | Jorge's preference over terracotta; university-press feel |
| Content cadence | Light updates | Projects/talks/bio a few times a year; blog is garnish, not the spine |
| Stack | Astro, custom CSS | Quarto's value (executable code cells) is unused; Bootstrap fights the design goal |
| Structure | Single page + essay pages | Six pages + navbar collapses into one scroll; modern, forces editorial discipline |

## Structure

One page, no navbar. Essay pages have just the name top-left as the way home.

1. **Opening** — Name, one positioning line ("I study how people live with chronic conditions — and how technology and AI can help."), 2–3 sentences of elaboration (Twente, Roessingh, tinnitus/chronic pain/mHealth). Rectangular editorial portrait, not a circle avatar. Contact as quiet text links (email · LinkedIn · Scholar).
2. **Selected work** — A typeset list (no cards): title + one-sentence description + link. Entries: chronic pain & AI, mobile health interventions, tinnitus newsletter (Substack), and a single "Publications → Google Scholar" line. The "Quarto Academic Theme" project is dropped.
3. **Writing** — Essay titles with dates. One entry today (the rooster essay); grows naturally.
4. **Footer** — Email again, ORCID/GitHub, one-line colophon.

The old About bio distills into the opening; personal warmth (family, fishing) may survive as one sentence.

## Visual system

**Typography**
- **Newsreader** (Google font, self-hosted) for display and body — optical sizes, editorial feel. Serif body text is what makes it feel literary.
- **Inter** (or system sans) only for small metadata: dates, tracked-out uppercase labels.
- Body ~1.15rem, line-height 1.65, measure ~65ch. Page should feel like a well-set book.

**Color** (all as CSS variables)
- Background: warm off-white `#FAF7F2`
- Ink: warm near-black `#211D17`; secondary `#6E655A`
- Accent: deep forest green `~#2F5D44` — links, small labels, optionally section headings
- Dark mode (cheap, optional): green-tinted charcoal `~#15211B` with cream text, via `prefers-color-scheme`

**Texture & restraint**
- No cards, boxes, shadows, or borders. Hierarchy from type scale and whitespace only.
- Sections separated by generous space + 1px hairline rules.
- Portrait: soft corners, sits quietly in the layout.

**Motion** — sophisticated, not invasive
- Sections fade up gently on first viewport entry (~300ms, small translate, once).
- Links grow underline on hover.
- Soft crossfade between pages via the View Transitions API.
- Nothing loops or bounces; everything respects `prefers-reduced-motion`.

## Stack & mechanics

- **Astro**, zero JS shipped except ~10 lines for scroll reveals.
- Layout:
  - `src/pages/index.astro` — the single page
  - `src/content/writing/*.md` — essays as markdown with frontmatter (rooster essay migrates as-is)
  - `src/layouts/` — base layout + essay layout
  - `src/styles/global.css` — entire design system, ~300 lines, hand-written
- Fonts self-hosted (no Google Fonts request — speed + GDPR).
- RSS feed kept for essays (`@astrojs/rss`).
- `_redirects` maps old Quarto URLs (`/about.html`, `/blog.html`, `/posts/...`, `/projects.html`, `/contact.html`) to new homes — no 404s on old links.
- Netlify build simplifies to `astro build` (replaces the script that downloads Quarto each deploy).
- Portrait optimized from 327KB PNG to ~40KB modern format.
- Updates remain trivial: edit markdown or ask Claude; push to deploy.

## Out of scope

- CMS, comments, analytics decisions, newsletter integration (Substack stays external).
- Computational/code-heavy blog tooling — explicitly not the future of this site.
