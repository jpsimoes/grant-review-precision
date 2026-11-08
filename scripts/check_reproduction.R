# Rscript --vanilla scripts/check_reproduction.R path/to/reference path/to/rerun
dirs <- commandArgs(trailingOnly = TRUE)
if (length(dirs) != 2L) stop("Supply the reference and rerun directories.")
dirs <- normalizePath(dirs, mustWork = TRUE)
if (dirs[1] == dirs[2]) stop("Supply distinct directories.")

inventory <- function(root, folders, ext) {
  files <- list.files(file.path(root, folders), pattern = ext, full.names = TRUE)
  sort(substring(files, nchar(root) + 2L))
}
reference_csv <- inventory(dirs[1], c("audit", "results", "data/derived"), "\\.csv$")
replicated_csv <- inventory(dirs[2], c("audit", "results", "data/derived"), "\\.csv$")
stopifnot(length(reference_csv) > 0L, identical(reference_csv, replicated_csv))
for (path in reference_csv) {
  files <- file.path(dirs, path)
  tables <- lapply(files, read.csv, stringsAsFactors = FALSE, check.names = FALSE)
  if (!identical(tables[[1]], tables[[2]])) stop("Cell or schema mismatch in ", path)
  message("Matched ", path, " (", nrow(tables[[1]]), " rows)")
}
pngs <- inventory(dirs[1], "figures", "\\.png$")
stopifnot(identical(pngs, c("figures/figure1.png", "figures/figure2.png")),
          identical(pngs, inventory(dirs[2], "figures", "\\.png$")))
for (path in pngs) {
  rasters <- lapply(file.path(dirs, path), png::readPNG, native = TRUE)
  if (!identical(rasters[[1]], rasters[[2]])) stop("PNG pixel mismatch in ", path)
  message("Matched ", path, " (", ncol(rasters[[1]]), " by ", nrow(rasters[[1]]), " pixels)")
}
