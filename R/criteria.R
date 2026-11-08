# Proposal-weighted marginal and distinct-reviewer pair tables for ordinal scores.
# Precomputing sufficient tables makes whole-proposal resampling inexpensive.
criterion_tables <- function(d, key) {
  # Negation places the best native grade last, as required by the probit cuts.
  x <- match(-d[[key]], sort(unique(-d[[key]])))
  y <- match(-d$overall, sort(unique(-d$overall)))
  proposals <- as.integer(factor(d$proposal_id))
  n <- tabulate(proposals)
  rows <- seq_len(nrow(d))
  pairs <- merge(data.frame(proposals, left = rows), data.frame(proposals, right = rows),
                 by = "proposals", sort = FALSE)
  pairs <- pairs[pairs$left != pairs$right, ]
  m <- n[pairs$proposals]
  nx <- max(x)
  ny <- max(y)
  sparse <- function(group, category, value, size) {
    Matrix::sparseMatrix(i = group, j = category, x = value, dims = c(length(n), size))
  }
  list(x = sparse(proposals, x, 1 / n[proposals], nx),
       y = sparse(proposals, y, 1 / n[proposals], ny),
       pairs = sparse(pairs$proposals, x[pairs$left] + nx * (y[pairs$right] - 1L),
                      1 / (m * (m - 1L)), nx * ny))
}

# Compute rectangular bivariate standard normal probabilities for two (possibly
# different) sets of cuts. Uniform endpoints are analytic, so no infinite
# quantile is supplied to pbivnorm.
criterion_rectangles <- function(px, py, rho) {
  fx <- c(0, cumsum(px)[-length(px)], 1)
  fy <- c(0, cumsum(py)[-length(py)], 1)
  grid <- matrix(0, length(fx), length(fy))
  grid[nrow(grid), ] <- fy
  grid[, ncol(grid)] <- fx
  ix <- seq.int(2L, length(fx) - 1L)
  iy <- seq.int(2L, length(fy) - 1L)
  zx <- qnorm(fx[ix])
  zy <- qnorm(fy[iy])
  grid[ix, iy] <- matrix(pbivnorm::pbivnorm(rep(zx, length(zy)),
                                            rep(zy, each = length(zx)), rho),
                         nrow = length(zx))
  vertical <- grid[-1L, , drop = FALSE] - grid[-nrow(grid), , drop = FALSE]
  vertical[, -1L, drop = FALSE] - vertical[, -ncol(vertical), drop = FALSE]
}

criterion_pair_fit <- function(tables, weights) {
  weighted <- function(x) as.numeric(Matrix::crossprod(weights, x))
  mx <- weighted(tables$x)
  my <- weighted(tables$y)
  pairs <- matrix(weighted(tables$pairs), length(mx), length(my))
  pairs <- pairs[mx > 0, my > 0, drop = FALSE]
  px <- mx[mx > 0] / sum(mx)
  py <- my[my > 0] / sum(my)
  stopifnot(length(px) > 1L, length(py) > 1L, sum(pairs) > 0)
  used <- pairs > 0
  loss <- function(rho) {
    prob <- criterion_rectangles(px, py, rho)[used]
    if (any(prob <= 0)) return(1e100)
    -sum(pairs[used] * log(prob))
  }
  fit <- optimize(loss, c(-0.995, 0.995), tol = 1e-7)
  if (abs(fit$minimum) > 0.9949) return(list(rho = NA_real_, cuts = numeric()))
  list(rho = fit$minimum, cuts = qnorm(cumsum(px)[-length(px)]))
}

# Expected Fisher information for a single criterion score conditional on
# unit-normal latent overall merit. Signed loadings may be negative.
criterion_information <- function(cuts, loading, theta) {
  if (!is.finite(loading) || abs(loading) >= 1) return(rep(NA_real_, length(theta)))
  residual_sd <- sqrt(1 - loading^2)
  vapply(theta, function(t) {
    z <- (c(-Inf, cuts, Inf) - loading * t) / residual_sd
    # Upper-tail CDF difference avoids cancellation for thresholds above zero.
    p <- diff(pnorm(z))
    upper <- head(z, -1) >= 0
    p[upper] <- -diff(pnorm(z, lower.tail = FALSE))[upper]
    derivative <- -loading / residual_sd * diff(dnorm(z))
    if (any(p <= 0)) return(NA_real_)
    sum(derivative^2 / p)
  }, numeric(1))
}

criterion_calibration <- function(tables, weights, theta) {
  baseline <- tables$overall
  anchor <- ordering_fit(baseline$counts, baseline$scores, weights)$rho
  # An anchor at the variance upper limit is an identification warning.
  if (anchor >= .999) anchor <- NA_real_
  do.call(rbind, lapply(setdiff(names(tables), "overall"), function(key) {
    pair <- criterion_pair_fit(tables[[key]], weights)
    loading <- if (is.finite(anchor) && anchor > 0) pair$rho / sqrt(anchor) else NA_real_
    information <- criterion_information(pair$cuts, loading, theta)
    data.frame(criterion = key, theta, anchor_rho = anchor, cross_rho = pair$rho,
               loading = loading, information = information)
  }))
}


criterion_dataset_tables <- function(data, criteria) {
  tables <- setNames(lapply(criteria, function(key) criterion_tables(data, key)), criteria)
  data$score <- -data$overall
  scores <- sort(unique(data$score))
  tables$overall <- list(counts = ordering_counts(data, scores)$counts, scores = scores)
  tables
}
