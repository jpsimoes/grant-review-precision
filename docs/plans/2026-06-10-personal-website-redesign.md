# Personal Website Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the Quarto/Bootstrap site with a single-page Astro site in a warm editorial style (serif typography, warm paper, deep green accent, soft animations), per `docs/plans/2026-06-10-personal-website-redesign-design.md`.

**Architecture:** Astro static site. One landing page (`index.astro`) containing intro, selected work, writing list, and footer; essays live as markdown in a content collection rendered at `/writing/<slug>/`. The entire design system is one hand-written CSS file. Zero client JS except a ~15-line IntersectionObserver for scroll reveals; page crossfades use native CSS `@view-transition`. Deployed on Netlify (build simplifies from "download Quarto" to `npm run build`).

**Tech Stack:** Astro ^6, @astrojs/rss, @fontsource-variable/newsreader (self-hosted font), plain CSS. No UI framework, no Tailwind, no client framework.

**Working directory:** `.worktrees/redesign` (branch `redesign`). All paths below are relative to the worktree root.

**Verification model:** This is a static site with no unit-test surface; the test equivalent used throughout is: `npm run build` must succeed, followed by `grep` assertions against `dist/` output, plus a final visual verification task. Run every command from the worktree root.

**Hard rule carried from the design:** no placeholder links anywhere. The old site shipped `yoursubstack.substack.com`, `github.com/YOURUSER`, and `href="#"` — none of these may survive. Every link in the new site is real or the element is omitted.

**Real link inventory (the only links allowed):**
- Email: `mailto:j.pianosimoes@utwente.nl`
- LinkedIn: `https://www.linkedin.com/in/jorge-piano-simoes-71671311a/`
- ORCID: `https://orcid.org/0000-0003-3397-2319`
- GitHub: `https://github.com/jpsimoes/`
- University: `https://people.utwente.nl/j.pianosimoes`
- Google Scholar: `https://scholar.google.com/citations?user=CBjxV3cAAAAJ&hl=en`
- CC license: `https://creativecommons.org/licenses/by-sa/4.0/`

---

### Task 1: Scaffold the Astro project

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Create: `tsconfig.json`
- Modify: `.gitignore`
- Create: `src/pages/index.astro` (temporary placeholder, replaced in Task 4)

**Step 1: Write `package.json`**

```json
{
  "name": "personal-website",
  "type": "module",
  "version": "2.0.0",
  "private": true,
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview"
  },
  "dependencies": {
    "@astrojs/rss": "^4.0.0",
    "@fontsource-variable/newsreader": "^5.0.0",
    "astro": "^6.0.0"
  }
}
```

**Step 2: Write `astro.config.mjs`**

```js
import { defineConfig } from 'astro/config';

export default defineConfig({
  // TODO(jorge): replace with the real production URL from the Netlify
  // dashboard before deploying (Site configuration → Domain management).
  site: 'https://example.com',
});
```

**Step 3: Write `tsconfig.json`**

```json
{
  "extends": "astro/tsconfigs/base",
  "include": [".astro/types.d.ts", "src/**/*"],
  "exclude": ["dist"]
}
```

**Step 4: Replace `.gitignore` contents entirely with:**

```
node_modules/
dist/
.astro/
.worktrees/
.DS_Store
/.quarto/
_site/
```

**Step 5: Write placeholder `src/pages/index.astro`**

```astro
---
---
<!doctype html>
<html lang="en">
  <head><meta charset="utf-8" /><title>Jorge Piano Simões</title></head>
  <body><h1>Scaffold OK</h1></body>
</html>
```

**Step 6: Install and build (the failing→passing check for this task)**

Run: `npm install`
Expected: completes without errors; `package-lock.json` and `node_modules/` appear.

Run: `npm run build`
Expected: ends with a line like `Complete!` / `1 page(s) built`; `dist/index.html` exists.

Run: `grep -c "Scaffold OK" dist/index.html`
Expected output: `1`

**Step 7: Commit**

```bash
git add package.json package-lock.json astro.config.mjs tsconfig.json .gitignore src/pages/index.astro
git commit -m "feat: scaffold Astro project"
```

---

### Task 2: Design system, base layout, favicon

**Files:**
- Create: `src/styles/global.css`
- Create: `src/layouts/Base.astro`
- Create: `public/favicon.svg`

**Step 1: Write `src/styles/global.css` (complete file)**

```css
/* ---------------------------------------------------------------
   Warm editorial design system.
   Paper, ink, one deep green. Hierarchy comes from type and space —
   no cards, no boxes, no shadows.
---------------------------------------------------------------- */

@import '@fontsource-variable/newsreader/opsz.css';
@import '@fontsource-variable/newsreader/opsz-italic.css';

:root {
  --paper: #faf7f2;
  --ink: #211d17;
  --ink-soft: #6e655a;
  --green: #2f5d44;
  --green-deep: #234734;
  --hairline: #e6dfd4;

  --serif: 'Newsreader Variable', 'Iowan Old Style', Georgia, serif;
  --sans: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif;

  --space: clamp(4.5rem, 10vh, 7rem);
}

@media (prefers-color-scheme: dark) {
  :root {
    --paper: #15211b;
    --ink: #ece5d8;
    --ink-soft: #9b9285;
    --green: #82bb9b;
    --green-deep: #a6d2ba;
    --hairline: #29382f;
  }
}

@view-transition {
  navigation: auto;
}

* {
  box-sizing: border-box;
}

html {
  background: var(--paper);
  color: var(--ink);
  font-family: var(--serif);
  font-size: 112.5%; /* 18px */
  -webkit-font-smoothing: antialiased;
  scroll-behavior: smooth;
}

body {
  margin: 0;
  line-height: 1.65;
}

main {
  max-width: 65ch;
  margin-inline: auto;
  padding: clamp(3.5rem, 9vh, 6.5rem) 1.4rem 4rem;
}

/* ---- typography ---- */

h1,
h2,
h3 {
  font-weight: 500;
  line-height: 1.15;
  text-wrap: balance;
  margin: 0;
}

h1 {
  font-size: clamp(2.1rem, 6vw, 3rem);
  font-variation-settings: 'opsz' 72;
  letter-spacing: -0.015em;
}

h2 {
  font-size: 1.4rem;
  color: var(--green);
  font-variation-settings: 'opsz' 36;
  margin-bottom: 1.6rem;
}

p {
  margin: 0 0 1.1em;
}

a {
  color: var(--green);
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.18em;
  text-decoration-color: color-mix(in srgb, var(--green) 40%, transparent);
  transition: text-decoration-color 250ms ease, color 250ms ease;
}

a:hover {
  color: var(--green-deep);
  text-decoration-color: currentColor;
}

::selection {
  background: color-mix(in srgb, var(--green) 20%, transparent);
}

.label {
  font-family: var(--sans);
  font-size: 0.72rem;
  font-weight: 500;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: var(--ink-soft);
}

/* ---- structure ---- */

section,
footer.colophon {
  margin-top: var(--space);
}

hr {
  border: 0;
  border-top: 1px solid var(--hairline);
  margin: var(--space) 0 0;
}

/* ---- landing page ---- */

.intro .role {
  color: var(--ink-soft);
  margin: 0.9rem 0 2rem;
}

.intro .contact-line {
  margin-top: 1.8rem;
}

.intro .contact-line a {
  color: var(--ink-soft);
  margin-right: 1.1rem;
}

.intro .contact-line a:hover {
  color: var(--green);
}

.portrait {
  display: block;
  margin-top: 2.6rem;
  border-radius: 10px;
  width: min(100%, 340px);
  height: auto;
}

.work-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.work-list li {
  padding: 1.35rem 0;
  border-top: 1px solid var(--hairline);
}

.work-list li:last-child {
  border-bottom: 1px solid var(--hairline);
}

.work-list h3 {
  font-size: 1.12rem;
}

.work-list p {
  margin: 0.35rem 0 0;
  color: var(--ink-soft);
  font-size: 0.95rem;
}

.essay-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.essay-list li {
  display: flex;
  align-items: baseline;
  gap: 1.2rem;
  padding: 0.55rem 0;
}

.essay-list time {
  flex-shrink: 0;
  min-width: 7.5rem;
}

footer.colophon p {
  color: var(--ink-soft);
  font-size: 0.88rem;
  margin-bottom: 0.4em;
}

footer.colophon .links a {
  margin-right: 1.1rem;
}

/* ---- essay pages ---- */

.crumb {
  margin-bottom: var(--space);
}

.crumb a {
  text-decoration: none;
  color: var(--ink-soft);
}

.crumb a:hover {
  color: var(--green);
}

.essay header h1 {
  font-size: clamp(1.8rem, 5vw, 2.4rem);
  margin-top: 0.5rem;
}

.essay header {
  margin-bottom: 3rem;
}

.prose {
  font-variation-settings: 'opsz' 16;
}

.prose p {
  margin-bottom: 1.25em;
}

.prose h2 {
  font-size: 1.3rem;
  margin: 2.2em 0 0.8em;
}

.prose blockquote {
  margin: 1.5em 0;
  padding-left: 1.25em;
  border-left: 2px solid var(--hairline);
  color: var(--ink-soft);
  font-style: italic;
}

/* ---- soft reveal ---- */

.reveal {
  opacity: 0;
  translate: 0 14px;
  transition: opacity 650ms ease-out, translate 650ms ease-out;
}

.reveal.is-visible {
  opacity: 1;
  translate: 0 0;
}

@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
  .reveal {
    opacity: 1;
    translate: none;
    transition: none;
  }
  a {
    transition: none;
  }
}
```

**Step 2: Write `src/layouts/Base.astro`**

```astro
---
import '../styles/global.css';

interface Props {
  title: string;
  description: string;
}

const { title, description } = Astro.props;
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="color-scheme" content="light dark" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={new URL(Astro.url.pathname, Astro.site)} />
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:type" content="website" />
    <link
      rel="alternate"
      type="application/rss+xml"
      title="Jorge Piano Simões — Writing"
      href={new URL('rss.xml', Astro.site)}
    />
    <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
    <meta name="generator" content={Astro.generator} />
  </head>
  <body>
    <slot />
    <script>
      const observer = new IntersectionObserver(
        (entries) => {
          for (const entry of entries) {
            if (entry.isIntersecting) {
              entry.target.classList.add('is-visible');
              observer.unobserve(entry.target);
            }
          }
        },
        { rootMargin: '0px 0px -8% 0px' }
      );
      document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
    </script>
  </body>
</html>
```

**Step 3: Write `public/favicon.svg`**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" rx="22" fill="#2f5d44"/>
  <text x="50" y="69" font-family="Georgia, 'Times New Roman', serif" font-size="56" fill="#faf7f2" text-anchor="middle">J</text>
</svg>
```

**Step 4: Verify build still passes**

Run: `npm run build`
Expected: build completes. (The layout isn't referenced yet — this checks the CSS imports resolve, i.e. the fontsource files exist at those paths. If `opsz.css`/`opsz-italic.css` don't resolve, check `ls node_modules/@fontsource-variable/newsreader/` and adjust the two `@import` lines to the closest equivalent, e.g. `index.css` + `wght-italic.css`.)

**Step 5: Commit**

```bash
git add src/styles/global.css src/layouts/Base.astro public/favicon.svg
git commit -m "feat: add warm editorial design system, base layout, favicon"
```

---

### Task 3: Content collection and essay migration

**Files:**
- Create: `src/content.config.ts`
- Create: `src/content/writing/rooster-soup-scapegoat.md`

**Step 1: Write `src/content.config.ts`**

```ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const writing = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/writing' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    description: z.string().optional(),
  }),
});

export const collections = { writing };
```

**Step 2: Create `src/content/writing/rooster-soup-scapegoat.md`**

Frontmatter (exactly this):

```yaml
---
title: "The Rooster, the Soup, and the Scapegoat"
date: 2024-12-12
description: "What a Janosch fable teaches about René Girard, mimetic desire, and the internet's appetite for scapegoats."
---
```

Body: copy **verbatim** from `posts/2024-12-12-rooster-soup-scapegoat.qmd` lines 10–40 (i.e. everything after the old frontmatter **and after the duplicated `## The Rooster...` heading on line 8** — the title must appear only once, rendered from frontmatter). Do not edit the prose. The old `image:`/`categories:` frontmatter fields are intentionally dropped; `img/janosch.jpg` was only a listing thumbnail and is not used in the new design.

**Step 3: Verify the collection parses**

Run: `npm run build`
Expected: build completes with no schema errors.

Run: `npx astro check 2>&1 | tail -5` (optional; don't block on warnings)

**Step 4: Commit**

```bash
git add src/content.config.ts src/content/writing/rooster-soup-scapegoat.md
git commit -m "feat: add writing collection and migrate rooster essay"
```

---

### Task 4: The landing page

**Files:**
- Move: `portrait.png` → `src/assets/portrait.png` (`git mv`)
- Replace: `src/pages/index.astro`

**Step 1: Move the portrait**

```bash
mkdir -p src/assets
git mv portrait.png src/assets/portrait.png
```

**Step 2: Replace `src/pages/index.astro` entirely with:**

```astro
---
import { getCollection } from 'astro:content';
import { Image } from 'astro:assets';
import Base from '../layouts/Base.astro';
import portrait from '../assets/portrait.png';

const essays = (await getCollection('writing')).sort(
  (a, b) => b.data.date.valueOf() - a.data.date.valueOf()
);

const fmt = (d: Date) =>
  d.toLocaleDateString('en-GB', { year: 'numeric', month: 'long', day: 'numeric' });
---

<Base
  title="Jorge Piano Simões"
  description="Health psychologist at the University of Twente working on chronic conditions, digital interventions, and AI."
>
  <main>
    <header class="intro reveal">
      <h1>Jorge Piano Simões</h1>
      <p class="role">
        Assistant Professor, Health Psychology, AI &amp; Technology ·
        <a href="https://people.utwente.nl/j.pianosimoes">University of Twente</a>
      </p>
      <p>
        I study how people live with chronic conditions — tinnitus, chronic pain,
        depression, anxiety — and how technology and AI can help them build lasting
        resilience.
      </p>
      <p>
        At the University of Twente and at Roessingh rehabilitation clinic in Enschede,
        I design and evaluate technology-based interventions for chronic pain. My work
        mixes therapeutic approaches (ACT, CBT, behaviour change) with machine learning,
        wearable sensors, and smartphone tracking — to understand what happens in
        people's daily lives, not just in the lab, and to figure out what works,
        for whom, and why.
      </p>
      <p>
        Away from work you'll find me with my three kids, at the lake with a fishing
        rod, or at the movies.
      </p>
      <p class="contact-line label">
        <a href="mailto:j.pianosimoes@utwente.nl">Email</a>
        <a href="https://www.linkedin.com/in/jorge-piano-simoes-71671311a/">LinkedIn</a>
        <a href="https://scholar.google.com/citations?user=CBjxV3cAAAAJ&hl=en">Scholar</a>
      </p>
      <Image
        class="portrait"
        src={portrait}
        alt="Portrait of Jorge Piano Simões"
        width={680}
        densities={[1, 2]}
        format="webp"
        quality={82}
      />
    </header>

    <hr />

    <section id="work" class="reveal">
      <h2>Selected work</h2>
      <ol class="work-list">
        <li>
          <h3>Chronic pain &amp; AI</h3>
          <p>
            Using machine learning on wearable-sensor data to predict flare-ups in
            chronic pain patients and model individual pain trajectories.
          </p>
        </li>
        <li>
          <h3>Mobile health interventions for tinnitus</h3>
          <p>
            Evaluating smartphone-based ecological momentary interventions for tinnitus
            distress in a randomised controlled trial.
          </p>
        </li>
        <li>
          <h3>
            <a href="https://scholar.google.com/citations?user=CBjxV3cAAAAJ&hl=en"
              >Publications on Google Scholar</a
            >
          </h3>
          <p>The full record — tinnitus heterogeneity, mHealth, systematic reviews.</p>
        </li>
      </ol>
    </section>

    <hr />

    <section id="writing" class="reveal">
      <h2>Writing</h2>
      <ol class="essay-list">
        {
          essays.map((essay) => (
            <li>
              <time class="label" datetime={essay.data.date.toISOString().slice(0, 10)}>
                {fmt(essay.data.date)}
              </time>
              <a href={`/writing/${essay.id}/`}>{essay.data.title}</a>
            </li>
          ))
        }
      </ol>
    </section>

    <hr />

    <footer class="colophon reveal">
      <p>
        Get in touch:
        <a href="mailto:j.pianosimoes@utwente.nl">j.pianosimoes@utwente.nl</a>
      </p>
      <p class="links label">
        <a href="https://www.linkedin.com/in/jorge-piano-simoes-71671311a/">LinkedIn</a>
        <a href="https://github.com/jpsimoes/">GitHub</a>
        <a href="https://orcid.org/0000-0003-3397-2319">ORCID</a>
        <a href="https://people.utwente.nl/j.pianosimoes">University</a>
      </p>
      <p>
        © 2026 Jorge Piano Simões · Writing licensed
        <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a> ·
        Set in Newsreader
      </p>
    </footer>
  </main>
</Base>
```

**Step 3: Build and assert content**

Run: `npm run build`
Expected: success; an optimized portrait appears under `dist/_astro/` as `.webp`.

Run these checks (each expected to print a match / count ≥ 1):

```bash
grep -c "Jorge Piano Simões" dist/index.html
grep -c "rooster-soup-scapegoat" dist/index.html
grep -c "j.pianosimoes@utwente.nl" dist/index.html
ls dist/_astro/ | grep -c webp
```

And the no-placeholder assertion (expected output: nothing, exit code 1):

```bash
grep -rn "YOURUSER\|yoursubstack\|href=\"#\"" dist/index.html
```

Check the optimized portrait is actually small:

```bash
find dist/_astro -name '*.webp' -exec ls -lh {} \;
```
Expected: well under 100KB. (Source was 327KB PNG.)

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: build single-page landing with intro, selected work, writing, footer"
```

---

### Task 5: Essay pages

**Files:**
- Create: `src/pages/writing/[id].astro`
- Delete: nothing yet (Quarto cleanup is Task 7)

**Step 1: Write `src/pages/writing/[id].astro`**

```astro
---
import { getCollection, render } from 'astro:content';
import Base from '../../layouts/Base.astro';

export async function getStaticPaths() {
  const essays = await getCollection('writing');
  return essays.map((essay) => ({
    params: { id: essay.id },
    props: { essay },
  }));
}

const { essay } = Astro.props;
const { Content } = await render(essay);

const fmt = (d: Date) =>
  d.toLocaleDateString('en-GB', { year: 'numeric', month: 'long', day: 'numeric' });
---

<Base title={`${essay.data.title} — Jorge Piano Simões`} description={essay.data.description ?? ''}>
  <main class="essay">
    <nav class="crumb label">
      <a href="/">← Jorge Piano Simões</a>
    </nav>
    <article>
      <header class="reveal">
        <time class="label" datetime={essay.data.date.toISOString().slice(0, 10)}>
          {fmt(essay.data.date)}
        </time>
        <h1>{essay.data.title}</h1>
      </header>
      <div class="prose reveal">
        <Content />
      </div>
    </article>
  </main>
</Base>
```

**Step 2: Build and assert**

Run: `npm run build`
Expected: success, now reporting 2+ pages.

```bash
test -f dist/writing/rooster-soup-scapegoat/index.html && echo EXISTS
grep -c "Girard" dist/writing/rooster-soup-scapegoat/index.html
grep -c "<h1" dist/writing/rooster-soup-scapegoat/index.html
```
Expected: `EXISTS`, a count ≥ 5, and exactly `1` h1 (title not duplicated — if 2, the old inline `##` heading leaked into the markdown body; remove it from the `.md` file).

**Step 3: Commit**

```bash
git add src/pages/writing
git commit -m "feat: add essay pages with editorial reading layout"
```

---

### Task 6: RSS, redirects, Netlify config

**Files:**
- Create: `src/pages/rss.xml.js`
- Create: `public/_redirects`
- Replace: `netlify.toml`

**Step 1: Write `src/pages/rss.xml.js`**

```js
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const essays = await getCollection('writing');
  return rss({
    title: 'Jorge Piano Simões — Writing',
    description: 'Essays on psychology, technology, and culture.',
    site: context.site,
    items: essays.map((essay) => ({
      title: essay.data.title,
      pubDate: essay.data.date,
      description: essay.data.description,
      link: `/writing/${essay.id}/`,
    })),
  });
}
```

**Step 2: Write `public/_redirects`** (old Quarto URLs → new homes; both `.html` and extensionless forms because Netlify pretty-URLs may have served either)

```
/about.html      /          301
/about           /          301
/projects.html   /#work     301
/projects        /#work     301
/blog.html       /#writing  301
/blog            /#writing  301
/contact.html    /          301
/contact         /          301
/posts/2024-12-12-rooster-soup-scapegoat.html  /writing/rooster-soup-scapegoat/  301
/posts/2024-12-12-rooster-soup-scapegoat       /writing/rooster-soup-scapegoat/  301
```

**Step 3: Replace `netlify.toml` entirely with:**

```toml
[build]
  command = "npm run build"
  publish = "dist"

[build.environment]
  NODE_VERSION = "22"
```

**Step 4: Build and assert**

Run: `npm run build`

```bash
test -f dist/rss.xml && echo RSS_OK
grep -c "rooster" dist/rss.xml
test -f dist/_redirects && echo REDIRECTS_OK
```
Expected: `RSS_OK`, `1` (or more), `REDIRECTS_OK`.

**Step 5: Commit**

```bash
git add src/pages/rss.xml.js public/_redirects netlify.toml
git commit -m "feat: add RSS feed, legacy redirects, simplified Netlify build"
```

---

### Task 7: Remove the Quarto site

**Files:**
- Delete (git rm): `index.qmd`, `about.qmd`, `blog.qmd`, `contact.qmd`, `projects.qmd`, `_quarto.yml`, `_defaults.yml`, `_metadata.yml`, `styles.scss`, `fa.html`, `posts/` (whole dir), `img/` (whole dir)
- Modify: `README.md`
- Note: `_site/` and root `.DS_Store` are tracked in git — they must be `git rm`'d, not just deleted from disk.

**Step 1: Remove Quarto files**

```bash
git rm index.qmd about.qmd blog.qmd contact.qmd projects.qmd _quarto.yml _defaults.yml _metadata.yml styles.scss fa.html
git rm -r posts img _site
git rm --cached .DS_Store 2>/dev/null; rm -f .DS_Store
rm -rf .quarto
```

(`portrait.png` was already moved in Task 4. The rooster essay content now lives in `src/content/writing/` — verify before deleting: `grep -c "Girard" src/content/writing/rooster-soup-scapegoat.md` must be ≥ 5.)

**Step 2: Replace `README.md` body** (keep it honest and short):

```markdown
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

\`\`\`bash
npm install
npm run dev
\`\`\`

## Adding an essay

Drop a markdown file in `src/content/writing/` with `title`, `date`, and
`description` frontmatter. It appears on the landing page and in the RSS feed.

## License

Content: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
```

(Unescape the backticks fence when writing the file.)

**Step 3: Full clean build from scratch**

```bash
rm -rf dist && npm run build
```
Expected: success. Then the global no-placeholder sweep (expected: no output, exit 1):

```bash
grep -rn "YOURUSER\|yoursubstack" --include='*.astro' --include='*.md' --include='*.html' src dist README.md
```

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove Quarto site, update README for Astro stack"
```

---

### Task 8: Visual verification and polish

**Files:** none planned — fix-ups only if checks fail.

**Step 1: REQUIRED SUB-SKILL — superpowers:verification-before-completion.** Run the dev server (`npm run dev`) and verify in a real browser (Claude Preview / playwright tools):

1. **Landing page, desktop (~1280px):** warm paper background, serif type, green section headings, hairline rules; portrait renders with rounded corners; intro fades up on load; work/writing sections fade up on scroll. No layout overflow.
2. **Dark mode** (emulate `prefers-color-scheme: dark`): green-tinted charcoal background, cream text, lightened green links — all text readable (contrast).
3. **Mobile (~390px):** single column reads comfortably; no horizontal scroll; tap targets sane.
4. **Reduced motion** (emulate `prefers-reduced-motion: reduce`): all content visible immediately, nothing animates.
5. **Essay page:** crumb link returns home; one `<h1>` only; prose comfortable (65ch, 18px serif); italics render (the essay uses them heavily).
6. **Links:** click every link once — every href resolves to a real page (no `#`, no placeholders).
7. **Console:** zero errors.

**Step 2: Screenshot** light + dark landing page and the essay page; show the user.

**Step 3: Confirm the one open TODO** — `site` in `astro.config.mjs` still says `https://example.com`; remind Jorge to set the real domain from the Netlify dashboard before merging/deploying (it only affects canonical/OG/RSS URLs, not rendering).

**Step 4: Commit any fixes, then REQUIRED SUB-SKILL: superpowers:requesting-code-review** against the design doc, followed by **superpowers:finishing-a-development-branch** (merge `redesign` → `main`, push, Netlify deploys).

---

## Out of scope (deliberate)

- Tinnitus newsletter entry — the old link was a template placeholder (`yoursubstack.substack.com`) and no real Substack was found; Jorge can add the entry with a real URL later as one `<li>` in the work list.
- Analytics, comments, sitemap, custom 404, newsletter signup — YAGNI until asked.
- Dark-mode toggle UI — `prefers-color-scheme` only, by design.
