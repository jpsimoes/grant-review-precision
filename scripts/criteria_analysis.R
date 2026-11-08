# Run from the repository root after scripts/us_prepare.R.
source("R/ordering.R")
source("R/criteria.R")
args <- commandArgs(trailingOnly = TRUE)
B <- if (length(args)) as.integer(args[1]) else 999L
stopifnot(is.finite(B), B >= 199)
d <- read.csv("data/derived/us_reviews.csv", colClasses = c(proposal_id = "character",
                                                             reviewer_id = "character"))
criteria <- c("approach", "significance", "innovation", "investigator")
percentile <- seq(.1, .9, by = .025)
theta <- qnorm(percentile)
set.seed(144088)
calibrate_dataset <- function(data) {
  tables <- criterion_dataset_tables(data, criteria)
  n <- nrow(tables$overall$counts)
  full <- criterion_calibration(tables, rep(1, n), theta)
  stopifnot(all(is.finite(full$information)))
  boot <- replicate(B, criterion_calibration(tables, tabulate(sample.int(n, replace = TRUE),
                                                              nbins = n), theta), simplify = FALSE)
  rows <- seq_len(nrow(full))
  info <- vapply(boot, function(b) b$information, numeric(nrow(full)))
  loadings <- vapply(boot, function(b) b$loading, numeric(nrow(full)))
  # Joint draw validity is retained for contrasts; unstable estimates are disclosed.
  interval <- function(m, p) apply(m, 1L, quantile, probs = p, na.rm = TRUE, names = FALSE)
  summary <- transform(full, dataset = data$dataset[1], percentile = rep(percentile, 4),
                       lower = interval(info, .025), upper = interval(info, .975),
                       loading_lower = interval(loadings, .025), loading_upper = interval(loadings, .975),
                       valid_boot = rowSums(is.finite(info)), boot_requested = B)
  # Family-wise intervals at the pre-specified 90th percentile over six contrasts.
  anchor <- rows[abs(summary$percentile - .9) < .0001]
  pairs <- combn(anchor, 2)
  delta <- full$information[pairs[1, ]] - full$information[pairs[2, ]]
  draws <- info[pairs[1, ], , drop = FALSE] - info[pairs[2, ], , drop = FALSE]
  complete <- apply(draws, 2, function(x) all(is.finite(x)))
  draws <- draws[, complete, drop = FALSE]
  spread <- apply(draws, 1, sd)
  threshold <- unname(quantile(apply(abs((draws - delta) / spread), 2, max), .95))
  contrasts <- data.frame(dataset = data$dataset[1], percentile = .9,
                          first = full$criterion[pairs[1, ]], second = full$criterion[pairs[2, ]],
                          diff = delta, simultaneous_lower = delta - threshold * spread,
                          simultaneous_upper = delta + threshold * spread,
                          valid_boot = sum(complete), boot_requested = B)
  list(summary = summary, contrasts = contrasts)
}
res <- lapply(split(d, d$dataset), calibrate_dataset)
out <- function(key) do.call(rbind, lapply(res, "[[", key))
dir.create("results", showWarnings = FALSE)
write.csv(out("summary"), "results/criteria_curves.csv", row.names = FALSE)
write.csv(out("contrasts"), "results/criteria_contrasts.csv", row.names = FALSE)
