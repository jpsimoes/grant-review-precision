# From the study root: Rscript --vanilla scripts/ordering_analysis.R
source("R/ordering.R")
us <- read.csv("data/derived/us_reviews.csv", colClasses = "character")
sw <- read.csv("data/derived/snsf_ratings.csv", colClasses = "character")
d <- rbind(data.frame(pool=us$dataset, scheme=us$dataset, proposal_id=us$proposal_id,
                      reviewer_id=us$reviewer_id, score = -as.numeric(us$overall), direction=-1),
           data.frame(pool=sw$panel_id, scheme=sw$scheme, proposal_id=sw$proposal_id,
                      reviewer_id=sw$reviewer_id, score=as.numeric(sw$score_higher_better), direction=1))
pools <- split(d, d$pool)
gap_levels <- c(.25, .5, 1)
targets <- c(.65, .7, .75, .8, .85, .9, .95)
nboot <- 400L
percentiles <- seq(.01, .99, .01)
quant <- function(x, p) unname(quantile(x, p, na.rm=TRUE))
run_pool <- function(pool, seed) {
  set.seed(seed)
  dat <- pools[[pool]]
  scores <- sort(unique(dat$score))
  count <- ordering_counts(dat, scores)$counts
  nprop <- nrow(count)
  fit <- ordering_fit(count, scores)
  sign <- unique(dat$direction)
  effect <- fit$rho
  diag_stats <- function(j) c(tie = sum(diag(j)), mad = sum(abs(outer(scores,scores,"-"))*j))
  diag_observed <- diag_stats(fit$pairs)
  diag_expected <- diag_stats(fit$model_pairs)
  cv <- ordering_cv(dat)
  diagnostics <- data.frame(pool, nprop, ratings=nrow(dat), categories=length(scores), rho=effect,
    observed_tie=diag_observed[1], fitted_tie=diag_expected[1],
    observed_pair_mad=diag_observed[2], fitted_pair_mad=diag_expected[2], cv$summary)
  grid <- expand.grid(percentile = percentiles, gap = gap_levels)
  # Restrict both endpoints to the expected plotting positions of this pool's
  # most extreme two latent values. This screening rule is an approximation.
  z <- qnorm(grid$percentile)
  grid$supported <- pnorm(z-grid$gap/2) >= 1/(nprop+1) &
                    pnorm(z+grid$gap/2) <= nprop/(nprop+1)
  grid$expected_beyond <- nprop * pmin(pnorm(z-grid$gap/2),
                                       pnorm(z+grid$gap/2, lower.tail=FALSE))
  assess <- function(f) ordering_curve(f, grid$percentile, grid$gap)
  accuracy <- assess(fit)
  ri <- factor(dat$reviewer_id)
  # Cluster multipliers are positive. Rare native categories remain represented.
  boot <- matrix(NA_real_, nrow(grid), nboot)
  two_way <- boot
  rho_p <- rho_tw <- numeric(nboot)
  for (b in seq_len(nboot)) {
    wp <- rexp(nprop)
    fp <- ordering_fit(count, scores, weights = wp)
    boot[,b] <- assess(fp)
    rho_p[b] <- fp$rho
    wr <- rexp(nlevels(ri))
    weighted <- ordering_counts(dat, scores, wr[ri])
    ft <- ordering_fit(weighted$counts, scores, wp, weighted$squares)
    two_way[,b] <- assess(ft)
    rho_tw[b] <- ft$rho
  }
  diagnostics$rho_lo <- quant(rho_p, .025)
  diagnostics$rho_hi <- quant(rho_p, .975)
  diagnostics$rho_lo_two_way <- quant(rho_tw, .025)
  diagnostics$rho_hi_two_way <- quant(rho_tw, .975)
  qs <- function(draws, p) apply(draws, 1, quant, p)
  curve <- data.frame(pool, scheme=unique(dat$scheme), grid, correct=accuracy,
    lo=qs(boot, .025), hi=qs(boot, .975),
    lo_two_way=qs(two_way, .025), hi_two_way=qs(two_way, .975),
    ordering_location(fit, grid$percentile, sign))
  boundaries <- list()
  for (gap in gap_levels) for (level in targets) for (support in c("order_positions","five_each_tail")) {
    g <- grid$gap == gap & grid$supported & grid$percentile >= .5 - 1e-9
    if (support == "five_each_tail") g <- g & grid$expected_beyond >= 5
    if (sum(g) < 2) next
    midpoint <- grid$percentile[g]
    calc <- function(values) ordering_crossing(midpoint, values, level)
    point <- calc(accuracy[g])
    crossing <- as.numeric(point[2])
    summarize_draws <- function(draws) {
      cros <- apply(draws[g,,drop=FALSE], 2, calc)
      hits <- cros[1,] == "terminal_crossing"
      values <- as.numeric(cros[2,hits])
      c(fraction_cross=mean(hits), fraction_point_status=mean(cros[1,] == point[1]),
        lower=if (any(hits)) quant(values,.025) else NA_real_,
        upper=if (any(hits)) quant(values,.975) else NA_real_)
    }
    boot_result <- summarize_draws(boot)
    tw_result <- summarize_draws(two_way)
    names(tw_result) <- paste0(names(tw_result), "_two_way")
    expected <- if (is.finite(crossing)) ordering_location(fit, crossing, sign)$expected_native else NA_real_
    boundaries[[length(boundaries)+1L]] <- data.frame(pool,gap,target=level,support,min_midpoint=min(midpoint),
      max_midpoint=max(midpoint), status=unname(point[1]), percentile=crossing,
      expected_native_score=expected,as.list(boot_result), as.list(tw_result),row.names=NULL)
  }
  # Drop unsupported points from the export; validation checks the kept range.
  list(curve=curve[curve$supported,], boundaries=do.call(rbind, boundaries),
       diagnostics=diagnostics, calibration=data.frame(pool, cv$calibration))
}
workers <- if (.Platform$OS.type == "windows") 1L else min(3L, length(pools))
res <- parallel::mclapply(seq_along(pools), function(i) run_pool(names(pools)[i], 20261108+i),
                          mc.cores=workers, mc.preschedule=FALSE)
stopifnot(all(vapply(res, is.list, logical(1))))
for (out in c("curve","boundaries","diagnostics","calibration")) {
  all_pools <- do.call(rbind,lapply(res,"[[",out))
  write.csv(all_pools,paste0("results/ordering_", out, ".csv"),row.names=FALSE, na="")
}
cat("Completed", length(res),"pool fits, calibrated accuracy curves and bootstrap analyses.\n")
