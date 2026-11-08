# Run with Rscript --vanilla scripts/reproduce.R from any working directory.
# Project resolution adapts the script-relative paths from the TGI-SR+ analysis.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(file_arg) != 1L) stop("Run this script with Rscript.")
file_path <- gsub("~+~", " ", sub("^--file=", "", file_arg), fixed = TRUE)
setwd(dirname(dirname(normalizePath(file_path, mustWork = TRUE))))

required <- c("digest", "igraph", "readxl", "Matrix", "pbivnorm", "statmod",
              "mirt", "ggplot2", "ragg", "systemfonts")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing))
  stop("Install these R packages and run again: ", paste(missing, collapse = ", "))
if (!capabilities("cairo")) stop("PDF figure export requires Cairo support in R.")
for (p in c("audit", "results", "figures"))
  dir.create(p, recursive = TRUE, showWarnings = FALSE)

steps <- c("us_prepare.R", "snsf_prepare.R", "check_tgi_precision.R",
           "criteria_checks.R", "ordering_analysis.R", "ordering_verify.R",
           "criteria_analysis.R", "criteria_sensitivity.R",
           "dimensionality_checks.R", "dimensionality_analysis.R",
           "snsf_three_vote_sensitivity.R", "criteria_figure.R", "ordering_figure.R")
runner <- file.path(R.home("bin"), "Rscript")
for (step in steps) {
  message("Running ", step)
  status <- system2(runner, c("--vanilla", shQuote(file.path("scripts", step))))
  if (status != 0L) stop(step, " stopped with exit status ", status)
}
message("Study data audits, analyses, sensitivity checks and figures are complete.")
