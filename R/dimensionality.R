# Cross-rater correlations implied by one overall-appraisal factor.
# Uses criterion_tables() and criterion_pair_fit() from R/criteria.R.
dimension_tables <- function(d, criteria) {
  stopifnot(!anyDuplicated(d[c("proposal_id", "reviewer_id")]),
            !anyNA(d[c("proposal_id", "reviewer_id", "overall", criteria)]))
  measures <- c("overall", criteria)
  pairs <- which(lower.tri(matrix(0, length(measures), length(measures)), diag = TRUE),
                 arr.ind = TRUE)
  tables <- lapply(seq_len(nrow(pairs)), function(k) {
    criterion_tables(d, measures[pairs[k, 1L]], measures[pairs[k, 2L]])
  })
  list(measures = measures, pairs = pairs, tables = tables,
       n = length(unique(d$proposal_id)))
}

dimension_estimates <- function(fit_data, weights) {
  # Both orientations of every rater pair contribute to each ordinal table.
  # Accordingly reversing the two variables would transpose the table.
  measures <- fit_data$measures
  R <- matrix(NA_real_, length(measures), length(measures),
              dimnames = list(measures, measures))
  R[fit_data$pairs] <- vapply(fit_data$tables, function(tab) {
    criterion_pair_fit(tab, weights)$rho
  }, numeric(1))
  observed <- R[-1L, -1L, drop = FALSE]
  anchor <- R[1L, 1L]
  cross <- R[-1L, 1L]
  consistent <- is.finite(anchor) && anchor > 0 && all(is.finite(cross)) &&
    all(abs(cross) < sqrt(anchor))
  implied <- if (consistent) tcrossprod(cross) / anchor else observed * NA_real_
  keep <- which(lower.tri(observed, diag = TRUE), arr.ind = TRUE)
  data.frame(first = rownames(observed)[keep[, 1]], second = colnames(observed)[keep[, 2]],
             overall_repeat = anchor, first_overall = cross[keep[, 1]],
             second_overall = cross[keep[, 2]], observed = observed[keep],
             implied = implied[keep], residual = observed[keep] - implied[keep],
             row.names = NULL)
}
