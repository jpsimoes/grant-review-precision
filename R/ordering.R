# Conditional ordering accuracy for three independent overall ratings per proposal.
# One row in a count matrix represents a proposal. Columns are observed native
# scores in ascending merit order. Larger values denote more favourable reviews.

ordering_joint <- function(cuts, rho) {
  n <- length(cuts) + 1L
  edge <- c(0, pnorm(cuts), 1)
  cdf <- matrix(0, n + 1L, n + 1L)
  cdf[n + 1L, ] <- edge
  cdf[, n + 1L] <- edge
  ii <- seq_along(cuts) + 1L
  cdf[ii, ii] <- matrix(pbivnorm::pbivnorm(rep(cuts, times = n - 1L),
                                            rep(cuts, each = n - 1L), rho),
                         n - 1L, n - 1L)
  left <- seq_len(n)
  right <- left + 1L
  pmax(cdf[right, right] - cdf[left, right] - cdf[right, left] + cdf[left, left], 0)
}

ordering_fit <- function(counts, scores, weights = rep(1, nrow(counts)),
                         squares = counts) {
  # With reviewer multiplier weights, squares contains sums of squared reviewer
  # weights by proposal and grade. Subtract self-pairs before normalising.
  size <- rowSums(counts)
  marg <- drop(crossprod(weights / size, counts)) / sum(weights)
  observed <- marg > 0
  count <- counts[, observed, drop = FALSE]
  squared <- squares[, observed, drop = FALSE]
  scores <- scores[observed]
  if (length(scores) < 2L) stop("Need two observed overall grades")
  cuts <- qnorm(head(cumsum(marg[observed]), -1L))
  denom <- size^2 - rowSums(squared)
  ok <- denom > 1e-8 * size^2
  w <- weights[ok] / denom[ok]
  cmat <- count[ok, , drop = FALSE]
  pairs <- crossprod(cmat, cmat * w)
  diag(pairs) <- diag(pairs) - drop(crossprod(w, squared[ok, , drop = FALSE]))
  pairs <- pmax(pairs, 0)
  pairs <- pairs / sum(pairs)
  active <- pairs > 0
  objective <- function(r) {
    joint <- ordering_joint(cuts, r)
    -sum(pairs[active] * log(pmax(joint[active], .Machine$double.xmin)))
  }
  interior <- optimize(objective, c(0, 0.999), tol = 1e-6)
  candidates <- c(0, interior$minimum, .999)
  rho <- candidates[which.min(c(objective(0), interior$objective, objective(.999)))]
  list(cuts = cuts, rho = rho, scores = scores, pairs = pairs,
       model_pairs = ordering_joint(cuts, rho), marginal = marg[observed])
}

ordering_category_probs <- function(fit, theta) {
  # The latent rating has marginal variance one. Theta has variance one across
  # proposals in this pool. Conditional variance is 1 - rho.
  cdf <- outer(theta, fit$cuts, function(t, b)
    pnorm((b - sqrt(fit$rho) * t) / sqrt(1 - fit$rho)))
  cdf <- cbind(0, cdf, 1)
  pmax(cdf[, -1L, drop = FALSE] - cdf[, -ncol(cdf), drop = FALSE], 0)
}

ordering_sum_probs <- function(prob, scores, reviewers) {
  # FFT computes the exact discrete convolution to floating point precision.
  step <- if (all(abs(scores - round(scores)) < 1e-9)) 1 else .1
  tick <- round((scores - min(scores)) / step)
  stopifnot(all(abs(tick * step - (scores - min(scores))) < 1e-8))
  size <- nextn(reviewers * max(tick) + 1L)
  padded <- matrix(0, nrow = size, ncol = nrow(prob))
  padded[tick + 1L, ] <- t(prob)
  total <- Re(mvfft(mvfft(padded)^reviewers, inverse = TRUE)) / size
  total <- pmax(total, 0)
  sweep(total, 2L, colSums(total), "/")
}

ordering_curve <- function(fit, percentile, gap, reviewers = 3L) {
  centre <- qnorm(percentile)
  low <- ordering_category_probs(fit, centre - gap / 2)
  high <- ordering_category_probs(fit, centre + gap / 2)
  p_low <- ordering_sum_probs(low, fit$scores, reviewers)
  p_high <- ordering_sum_probs(high, fit$scores, reviewers)
  # Half-credit ties gives equal latent proposals exactly 0.5.
  lower <- apply(p_low, 2L, cumsum) - .5 * p_low
  colSums(lower * p_high)
}

ordering_counts <- function(d, values, reviewer_weights = rep(1, nrow(d))) {
  # Proposal levels and reviewer identifiers have pool-specific meanings.
  p <- factor(d$proposal_id)
  k <- match(d$score, values)
  index <- as.integer(p) + (k - 1L) * nlevels(p)
  group_sums <- function(w) {
    cells <- numeric(nlevels(p) * length(values))
    values_by_cell <- rowsum(w, index, reorder = FALSE)
    cells[as.integer(rownames(values_by_cell))] <- values_by_cell[, 1L]
    matrix(cells, nrow = nlevels(p), dimnames = list(levels(p), as.character(values)))
  }
  list(counts = group_sums(reviewer_weights), squares = group_sums(reviewer_weights^2))
}

ordering_location <- function(fit, percentile, score_direction = 1) {
  # Adapted from TGI-SR+'s expected-score grid; in this ordinal-probit model
  # the expected native score is the probability-weighted sum of grade values.
  theta <- qnorm(percentile)
  prob <- ordering_category_probs(fit, theta)
  density <- outer(theta, fit$cuts, function(t,b)
    dnorm((b - sqrt(fit$rho)*t)/sqrt(1-fit$rho)) * -sqrt(fit$rho/(1-fit$rho)))
  slope <- cbind(density, 0) - cbind(0, density)
  terms <- slope^2 / prob
  terms[prob == 0] <- 0
  data.frame(expected_native = drop(prob %*% fit$scores) * score_direction,
             information_three = 3 * rowSums(terms))
}

ordering_crossing <- function(p, correct, level) {
  # Last downward crossing of the target on the supported upper half.
  if (all(correct < level)) return(c(status = "below_throughout", percentile = NA))
  if (all(correct >= level)) return(c(status = "at_or_above_throughout", percentile = NA))
  if (tail(correct, 1) >= level) return(c(status = "no_terminal_loss", percentile = NA))
  j <- max(which(correct >= level))
  crossing <- p[j] + (p[j+1] - p[j]) * (level-correct[j])/(correct[j+1] - correct[j])
  c(status = "terminal_crossing", percentile = as.character(crossing))
}

ordering_cv <- function(d, nfold = 5L) {
  # Assign whole proposals to folds before fitting. Evaluate all three rotations
  # of one sampled trio per proposal so every score in each trio serves as target.
  by_id <- split(seq_len(nrow(d)), d$proposal_id)
  groups <- sample(rep(seq_len(nfold), length.out = length(by_id)))
  names(groups) <- names(by_id)
  out <- list()
  nodes <- statmod::gauss.quad.prob(41, dist = "normal")
  best <- max(d$score)
  for (fold in seq_len(nfold)) {
    test <- names(groups)[groups == fold]
    train <- d[!d$proposal_id %in% test, ]
    values <- sort(unique(train$score))
    fit <- ordering_fit(ordering_counts(train, values)$counts, values)
    probs <- ordering_category_probs(fit, nodes$nodes)
    expectation <- drop(probs %*% values)
    likelihood <- crossprod(probs, probs * nodes$weights)
    cond_mean <- crossprod(probs, probs * (nodes$weights * expectation)) / likelihood
    top_probability <- if (best %in% values) probs[, match(best, values)] else rep(0, nrow(probs))
    cond_top <- crossprod(probs, probs * (nodes$weights * top_probability)) / likelihood
    base <- sum(fit$marginal * values)
    for (id in test) {
      rows <- by_id[[id]]
      if (length(rows) < 3L) next
      s <- d$score[sample(rows, 3L)]
      iz <- match(s, values)
      ij <- cbind(iz[c(2,3,1)], iz[c(3,1,2)])
      est <- cond_mean[ij]
      out[[length(out)+1L]] <- data.frame(id = id, observed = s, predicted = est,
        predicted_top = cond_top[ij], base = base, raw = (sum(s) - s) / 2)
    }
  }
  out <- do.call(rbind, out)
  valid <- is.finite(out$predicted)
  err <- function(v) sqrt(mean((out$observed[valid] - v[valid])^2))
  summary <- data.frame(cv_proposals = length(unique(out$id)), cv_targets = nrow(out),
             cv_scored = sum(valid), rmse_model = err(out$predicted),
             rmse_pool_mean = err(out$base), rmse_two_score_mean = err(out$raw))
  scored <- out[valid,]
  cutoff <- quantile(scored$predicted, .75, type=1, names=FALSE)
  group <- ifelse(scored$predicted >= cutoff, "upper_quartile", "remaining")
  direction <- unique(d$direction)
  calibration <- do.call(rbind, lapply(split(scored, group), function(s) {
    data.frame(n_predictions=nrow(s), n_proposals=length(unique(s$id)),
               predicted_native=mean(s$predicted) * direction,
               observed_native=mean(s$observed) * direction,
               predicted_best=mean(s$predicted_top), observed_best=mean(s$observed == best))
  }))
  calibration$group <- rownames(calibration)
  calibration$predicted_native_at_quartile <- cutoff * direction
  rownames(calibration) <- NULL
  list(summary=summary, calibration=calibration)
}
