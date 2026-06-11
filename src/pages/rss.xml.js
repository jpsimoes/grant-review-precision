import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const essays = (await getCollection('writing')).sort(
    (a, b) => b.data.date.valueOf() - a.data.date.valueOf()
  );
  return rss({
    title: 'Jorge Piano Simões — Writing',
    description: 'Essays on psychology, technology, and culture.',
    site: context.site,
    xmlns: { atom: 'http://www.w3.org/2005/Atom' },
    customData: [
      '<language>en</language>',
      `<atom:link href="${new URL('rss.xml', context.site)}" rel="self" type="application/rss+xml"/>`,
    ].join(''),
    items: essays.map((essay) => ({
      title: essay.data.title,
      pubDate: essay.data.date,
      description: essay.data.description,
      link: `/writing/${essay.id}/`,
    })),
  });
}
