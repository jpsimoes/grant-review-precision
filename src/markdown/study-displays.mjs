// Preserve each Markdown table's header associations when the study is read
// as a row-by-row list on narrow screens.
const elements = (node) => node.children.filter((child) => child.type === 'element');
const textOf = (node) => node.type === 'text' ? node.value : node.children.map(textOf).join('');

function labelReviewSettings(table) {
  const [head, body] = elements(table);
  const headings = elements(elements(head)[0]);
  table.properties.className = ['review-settings'];
  table.properties.role = 'table';
  head.properties.role = body.properties.role = 'rowgroup';
  elements(head)[0].properties.role = 'row';
  for (const heading of headings) {
    Object.assign(heading.properties, { scope: 'col', role: 'columnheader' });
  }
  for (const row of elements(body)) {
    row.properties.role = 'row';
    const [setting, ...cells] = elements(row);
    setting.tagName = 'th';
    Object.assign(setting.properties, { scope: 'row', role: 'rowheader' });
    cells.forEach((cell, index) => {
      cell.properties.role = 'cell';
      cell.children.unshift({
        type: 'element', tagName: 'span',
        properties: { className: ['mobile-table-label'], ariaHidden: 'true' },
        children: [{ type: 'text', value: textOf(headings[index + 1]) }],
      });
    });
  }
}

export default function studyDisplays() {
  return (tree, file) => {
    if (!file.path?.endsWith('/grant-review-precision.md')) return;
    for (const node of elements(tree)) {
      if (node.tagName === 'table') labelReviewSettings(node);
    }

    for (let index = 0; index < tree.children.length; index++) {
      const paragraph = tree.children[index];
      if (paragraph.tagName !== 'p') continue;
      const [link] = elements(paragraph);
      if (link?.tagName !== 'a' || elements(link)[0]?.tagName !== 'img') continue;
      let next = index + 1;
      while (tree.children[next]?.type === 'text' && !tree.children[next].value.trim()) next++;
      const caption = tree.children[next];
      if (caption?.tagName !== 'p' || !/^Figure \d+\./.test(textOf(caption))) continue;
      caption.tagName = 'figcaption';
      tree.children.splice(index, next - index + 1, {
        type: 'element', tagName: 'figure', properties: { className: ['study-figure'] },
        children: [link, caption],
      });
    }
  };
}
