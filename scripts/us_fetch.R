# Run from the repository root with Rscript --vanilla scripts/us_fetch.R.
# The package distributes the review-level versions analysed by Erosheva et al.
sources <- data.frame(
  dataset = c("NIH", "AIBS"),
  sha256 = c(
    "5f137a5573705cfbf50282801b3aa9cdc00ceb613fa439ea13a76bc99f9df0eb",
    "0ab9087f10283715aa6bb9d50745a0580ee7902ca2bca3daa8f870b20c6bf57f"
  )
)
sources$url <- sprintf(
  "https://raw.githubusercontent.com/cran/ShinyItemAnalysis/1.5.1/data/%s.rda",
  sources$dataset
)
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

fetch_file <- function(dataset, url, sha256) {
  destination <- file.path("data/raw", paste0(dataset, ".rda"))
  matches <- function(path) {
    identical(digest::digest(path, algo = "sha256", file = TRUE), sha256)
  }
  if (file.exists(destination)) {
    if (!matches(destination)) stop("Checksum mismatch for ", destination)
    return(invisible(destination))
  }
  temporary <- tempfile(pattern = dataset, tmpdir = dirname(destination))
  on.exit(unlink(temporary), add = TRUE)
  utils::download.file(url, temporary, mode = "wb", quiet = TRUE)
  if (!matches(temporary)) stop("Downloaded bytes failed verification for ", dataset)
  if (!file.rename(temporary, destination)) stop("Cannot write ", destination)
}
invisible(Map(fetch_file, sources$dataset, sources$url, sources$sha256))
