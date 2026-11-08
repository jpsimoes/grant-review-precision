"""Build the source and aggregate-results ZIP. Run from any directory."""
import argparse
import hashlib
import os
from pathlib import Path
import tempfile
from zipfile import ZIP_STORED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = "grant-review-precision"
REQUIRED = {
    "": ("README.md", "CITATION.cff", "LICENSE.md", "LICENSE-CODE.txt"),
    "R": ("criteria.R", "dimensionality.R", "figure_theme.R", "ordering.R", "tgi_precision.R"),
    "article": ("article.md",),
    "audit": (
        "us_data.md", "us_sources.csv", "us_scales.csv", "us_review_counts.csv",
        "us_assignments.csv", "us_strata.csv", "snsf_compatibility.md",
        "snsf_panels.csv", "snsf_three_vote_sensitivity.csv",
    ),
    "docs": ("environment.csv", "reproduction.md", "tgi-reuse.md"),
    "methods": ("README.md", "criteria.md", "design.md", "dimensionality.md", "ordering.md"),
    "results": (
        "criteria_aibs_influence.csv", "criteria_contrasts.csv", "criteria_curves.csv",
        "criteria_prediction_checks.csv", "dimensionality_residuals.csv", "ordering_boundaries.csv", "ordering_calibration.csv",
        "ordering_curve.csv", "ordering_diagnostics.csv",
    ),
    "figures": ("figure1.pdf", "figure1.png", "figure2.pdf", "figure2.png"),
    "scripts": (
        "check_reproduction.R", "check_tgi_precision.R", "criteria_analysis.R",
        "criteria_checks.R", "criteria_figure.R", "criteria_sensitivity.R",
        "dimensionality_analysis.R", "dimensionality_checks.R",
        "ordering_analysis.R", "ordering_figure.R", "ordering_verify.R", "package_release.py",
        "render_article.py", "reproduce.R", "snsf_prepare.R", "snsf_three_vote_sensitivity.R",
        "stage_website.py", "us_fetch.R", "us_prepare.R",
    ),
}


def build(root, output):
    root = root.resolve(strict=True)
    files = [Path(folder, name) for folder, names in REQUIRED.items() for name in names]
    files.sort(key=lambda path: path.as_posix())
    for relative in files:
        path = root / relative
        if not path.is_file() or path.resolve() != path:
            raise ValueError(f"Expected a regular project file at {relative}")

    output = output.absolute()
    if output.suffix.lower() != ".zip":
        raise ValueError("The output must have a .zip extension.")
    output.parent.mkdir(parents=True, exist_ok=True)
    # A fixed timestamp, permissions and uncompressed payload give identical bytes
    # across filesystems and compression libraries for identical source contents.
    with tempfile.NamedTemporaryFile(dir=output.parent, delete=False) as temp:
        temporary = Path(temp.name)
    try:
        with ZipFile(temporary, "w", compression=ZIP_STORED) as archive:
            for relative in files:
                info = ZipInfo(f"{PACKAGE}/{relative.as_posix()}", date_time=(1980, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                archive.writestr(info, (root / relative).read_bytes())
        with ZipFile(temporary) as archive:
            if archive.testzip() is not None or len(archive.namelist()) != len(files):
                raise RuntimeError("Archive integrity check failed.")
        os.replace(temporary, output)
    finally:
        temporary.unlink(missing_ok=True)
    return len(files), hashlib.sha256(output.read_bytes()).hexdigest()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "release" / f"{PACKAGE}-source.zip")
    args = parser.parse_args()
    count, digest = build(ROOT, args.output)
    print(f"{args.output} ({count} files)\nSHA-256 {digest}")
