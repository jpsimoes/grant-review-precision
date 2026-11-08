"""Copy the current article, its two images and the publication PDF to an Astro checkout."""
import argparse
from pathlib import Path
import re
from shutil import copyfile

ROOT = Path(__file__).resolve().parents[1]
SLUG = "grant-review-precision"
URL_PREFIX = f"/files/{SLUG}/"


def stage_site(checkout):
    article = (ROOT / "article" / "article.md").read_text(encoding="utf-8")
    if not article.startswith("---\n") or "\n---\n" not in article[4:]:
        raise ValueError("The article must have YAML frontmatter")
    fields, body = article[4:].split("\n---\n", 1)
    if any(line.startswith("pdf:") for line in fields.splitlines()):
        raise ValueError("Remove the duplicate PDF field from the source frontmatter")
    content = checkout / "src/content/writing"
    if not content.is_dir() or not (checkout / "astro.config.mjs").is_file():
        raise ValueError("Expected an Astro writing collection in the destination")
    assets = [ROOT / "figures" / f"figure{i}.png" for i in (1, 2)]
    pdf = ROOT / "release" / f"{SLUG}.pdf"
    for asset in [*assets, pdf]:
        if not asset.is_file():
            raise FileNotFoundError(asset)
    for figure in assets:
        image = rf"!\[([^\]\n]*)\]\(\.\./figures/{re.escape(figure.name)}\)"
        url = URL_PREFIX + figure.name
        body, count = re.subn(image, lambda m: f"[![{m[1]}]({url})]({url})", body)
        if count != 1:
            raise ValueError(f"Expected one image reference for {figure.name}")
    fields += f'\npdf: "{URL_PREFIX}{pdf.name}"'
    destination = checkout / "public" / URL_PREFIX.strip("/")
    destination.mkdir(parents=True, exist_ok=True)
    for asset in [*assets, pdf]:
        copyfile(asset, destination / asset.name)
    (content / f"{SLUG}.md").write_text(f"---\n{fields}\n---\n{body}", encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("checkout", type=Path)
    stage_site(parser.parse_args().checkout.resolve())
