"""Render the study Markdown with Pandoc 3 and ReportLab 4.

Run from any directory. Optional arguments are the source and output paths.
"""
import argparse
import json
import os
import subprocess
from datetime import date, datetime, timezone
from pathlib import Path
from xml.sax.saxutils import escape, quoteattr

import reportlab
from reportlab.lib import colors
from reportlab.lib.enums import TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Image, KeepTogether, Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

ROOT = Path(__file__).resolve().parents[1]
INK = "#211D17"
GREEN = "#2F5D44"
MUTED = "#6E655A"
TEXT_WIDTH = A4[0] - 120


def inline(nodes):
    parts = []
    for node in nodes:
        kind, content = node["t"], node.get("c")
        if kind == "Str":
            parts.append(escape(content))
        elif kind in ("Space", "SoftBreak", "LineBreak"):
            parts.append(" ")
        elif kind in ("Emph", "Strong"):
            tag = "i" if kind == "Emph" else "b"
            parts.append(f"<{tag}>{inline(content)}</{tag}>")
        elif kind == "Link":
            parts.append(f'<link color="{GREEN}" underline="1" href={quoteattr(content[2][0])}>{inline(content[1])}</link>')
        elif kind == "Code":
            parts.append(escape(content[1]))
        else:
            raise ValueError(f"Unsupported inline element: {kind}")
    return "".join(parts)


def style(name, font, size, leading, **options):
    return ParagraphStyle(name, fontName=font, fontSize=size, leading=leading,
                          textColor=colors.HexColor(INK), **options)


def build(source, output):
    fonts = Path(reportlab.__file__).parent / "fonts"
    for name, filename in [("Vera", "Vera.ttf"), ("Vera-Bold", "VeraBd.ttf"),
                           ("Vera-Italic", "VeraIt.ttf"), ("Vera-BoldItalic", "VeraBI.ttf")]:
        pdfmetrics.registerFont(TTFont(name, str(fonts / filename)))
    pdfmetrics.registerFontFamily("Vera", normal="Vera", bold="Vera-Bold",
                                 italic="Vera-Italic", boldItalic="Vera-BoldItalic")
    ast = json.loads(subprocess.check_output(["pandoc", "--from=gfm+yaml_metadata_block",
                                              "--to=json", str(source)]))
    meta = {key: inline(value["c"]) for key, value in ast["meta"].items()
            if value["t"] == "MetaInlines"}
    published = date.fromisoformat(meta["date"])
    midnight = datetime(published.year, published.month, published.day, tzinfo=timezone.utc)
    os.environ.setdefault("SOURCE_DATE_EPOCH", str(int(midnight.timestamp())))
    output.parent.mkdir(parents=True, exist_ok=True)
    doc = SimpleDocTemplate(str(output), pagesize=A4, leftMargin=54, rightMargin=54,
                            topMargin=44, bottomMargin=47, title=meta["title"],
                            author=meta["author"], subject=meta["description"],
                            invariant=1)
    heading = style("Heading", "Times-Bold", 18, 22, spaceBefore=9, spaceAfter=6,
                    keepWithNext=True)
    body = style("Body", "Times-Roman", 12, 16, spaceAfter=8, allowWidows=0, allowOrphans=0)
    caption = style("Caption", "Vera", 8.5, 12.3, spaceAfter=9)
    title = style("Title", "Times-Bold", 31, 33, spaceAfter=11)
    byline = style("Byline", "Vera-Bold", 9, 12, spaceAfter=9)
    pubdate = published.strftime("%d %B %Y").lstrip("0")
    story = [Paragraph(meta["title"], title),
             Paragraph(f'{meta["author"]} &nbsp;·&nbsp; {pubdate}', byline)]
    pending_figure = None
    for block in ast["blocks"]:
        kind, content = block["t"], block["c"]
        if kind in ("Para", "Plain") and len(content) == 1 and content[0]["t"] == "Image":
            if pending_figure:
                story.extend([pending_figure, Spacer(1, 7)])
            figure = Image(str(source.parent / content[0]["c"][2][0]))
            scale = min(TEXT_WIDTH / figure.imageWidth, A4[1] * 0.46 / figure.imageHeight)
            figure.drawWidth = figure.imageWidth * scale
            figure.drawHeight = figure.imageHeight * scale
            pending_figure = figure
            continue
        if pending_figure:
            if kind in ("Para", "Plain") and "Figure" in inline(content)[:24]:
                story.append(KeepTogether([pending_figure, Spacer(1, 4),
                                           Paragraph(inline(content), caption)]))
                pending_figure = None
                continue
            story.extend([pending_figure, Spacer(1, 7)])
            pending_figure = None
        if kind in ("Para", "Plain"):
            story.append(Paragraph(inline(content), body))
        elif kind == "Header":
            story.append(Paragraph(inline(content[2]), heading))
        elif kind == "Table":
            head, bodies = content[3][1], content[4]
            rows = head + [row for group in bodies for row in group[3]]
            data = []
            for index, row in enumerate(rows):
                cells = []
                for col, cell in enumerate(row[1]):
                    right_aligned = content[2][col][0]["t"] == "AlignRight"
                    cell_style = style("Cell", "Vera-Bold" if index < len(head) else "Vera",
                                       8.1, 11.1, alignment=TA_RIGHT if right_aligned else 0)
                    cells.append(Paragraph(" ".join(inline(b["c"]) for b in cell[4]), cell_style))
                data.append(cells)
            widths = {4: (.36, .135, .115, .39), 5: (.31, .118, .096, .16, .316)}
            table = Table(data, colWidths=[TEXT_WIDTH * f for f in widths[len(data[0])]],
                          repeatRows=len(head), hAlign="LEFT")
            table.setStyle(TableStyle([
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LINEABOVE", (0, 0), (-1, 0), .8, colors.HexColor(GREEN)),
                ("LINEBELOW", (0, 0), (-1, -1), .35, colors.HexColor("#D7CFC2")),
                ("LEFTPADDING", (0, 0), (-1, -1), 3.5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3.5),
                ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5)]))
            story.extend([KeepTogether([table]), Spacer(1, 9)])
        else:
            raise ValueError(f"Unsupported block: {kind}")
    if pending_figure:
        story.append(pending_figure)

    def footer(canvas, document):
        canvas.saveState()
        canvas.setStrokeColor(colors.HexColor("#D7CFC2"))
        canvas.setLineWidth(.4)
        canvas.line(60, 39, A4[0] - 60, 39)
        canvas.setFillColor(colors.HexColor(MUTED))
        canvas.setFont("Vera", 7.8)
        canvas.drawString(60, 25, "Jorge Piano Simões  ·  Grant review precision")
        canvas.drawRightString(A4[0] - 60, 25, str(document.page))
        canvas.restoreState()

    doc.build(story, onFirstPage=footer, onLaterPages=footer)


if __name__ == "__main__":
    args = argparse.ArgumentParser(description=__doc__)
    args.add_argument("source", nargs="?", type=Path, default=ROOT / "article/article.md")
    args.add_argument("output", nargs="?", type=Path, default=ROOT / "release/grant-review-precision.pdf")
    options = args.parse_args()
    build(options.source.resolve(), options.output.resolve())
