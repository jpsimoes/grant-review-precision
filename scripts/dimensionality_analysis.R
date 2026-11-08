# Post hoc diagnostic. Each criterion pair uses scores from different reviewers.
source("R/criteria.R")
source("R/dimensionality.R")
d <- read.csv("data/derived/us_reviews.csv", colClasses = c(proposal_id = "character",
                                                             reviewer_id = "character"))
criteria <- c("approach", "significance", "investigator", "innovation")
B <- 999L
set.seed(740038)
assess <- function(data) {
  fit_data <- dimension_tables(data, criteria)
  full <- dimension_estimates(fit_data, rep(1L, fit_data$n))
  stopifnot(all(is.finite(full$residual)))
  # Generate all draw weights before forking for reproducibility on Windows.
  weights <- replicate(B, tabulate(sample.int(fit_data$n, replace = TRUE), nbins = fit_data$n),
                       simplify = FALSE)
  workers <- if (.Platform$OS.type == "windows") 1L else 3L
  boot <- parallel::mclapply(weights, function(w) dimension_estimates(fit_data, w)$residual,
                            mc.cores = workers, mc.set.seed = FALSE)
  draws <- do.call(cbind, boot)
  valid <- apply(draws, 2L, function(v) all(is.finite(v)))
  if (sum(valid) < .95 * B) stop("Too few identified bootstrap fits in ", data$dataset[1])
  draws <- draws[, valid, drop = FALSE]
  se <- apply(draws, 1L, sd)
  stopifnot(all(se > 0))
  largest <- apply(abs((draws - full$residual) / se), 2L, max)
  multiplier <- unname(quantile(largest, .95))

  # Omit every AIBS reviewer in turn. NIH has 4,555 reviewers: assign them to
  # ten disjoint groups by cycling through decreasing workloads. Lexical ID
  # order breaks workload ties. Each refit removes a comparable share of rows.
  workload <- table(data$reviewer_id)
  ids <- names(workload)[order(-as.numeric(workload), names(workload), method = "radix")]
  n_groups <- if (data$dataset[1] == "AIBS") length(ids) else 10L
  groups <- split(ids, rep_len(seq_len(n_groups), length(ids)))
  omit <- lapply(groups, function(ids) {
    keep <- !data$reviewer_id %in% ids
    reduced <- dimension_tables(data[keep, ], criteria)
    dimension_estimates(reduced, rep(1L, reduced$n))$residual
  })
  omitted <- do.call(cbind, omit)
  stopifnot(all(is.finite(omitted)))
  transform(full, dataset = data$dataset[1], proposals = fit_data$n,
            multiply_reviewed = sum(table(data$proposal_id) > 1L),
            simultaneous_lower = residual - multiplier * se,
            simultaneous_upper = residual + multiplier * se,
            valid_boot = sum(valid), boot_requested = B,
            reviewer_omissions = n_groups, omission_min = apply(omitted, 1L, min),
            omission_max = apply(omitted, 1L, max))
}
out <- do.call(rbind, lapply(split(d, d$dataset), assess))
dir.create("results", showWarnings = FALSE)
write.csv(out, "results/dimensionality_residuals.csv", row.names = FALSE)
