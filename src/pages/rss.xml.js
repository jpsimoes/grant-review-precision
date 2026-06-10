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
