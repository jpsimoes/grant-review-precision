# Finite-panel sensitivity using only disjoint reference and test votes.
# Run after scripts/snsf_prepare.R.
# A rank comparison is scored 1 for agreement, 0 for disagreement, .5 for a tie.

votes <- read.csv("data/derived/snsf_ratings.csv")
mint <- votes[votes$scheme == "Project Funding", ]

# Index all triples and the test triples that use none of the reference voters.
three_vote_design <- function(n) {
  triples <- t(combn(n, 3))
  test_index <- t(vapply(seq_len(nrow(triples)), function(i) {
    reference <- triples[i, ]
    which(rowSums(matrix(triples %in% reference, nrow = nrow(triples))) == 0L)
  }, integer(choose(n - 3, 3))))
  list(triples = triples, test_index = test_index)
}
designs <- lapply(setNames(7:9, 7:9), three_vote_design)

pair_results <- function(a, b) {
  common <- !is.na(a) & !is.na(b)
  n <- sum(common)
  # A common pool of four or more test voters permits different test trios.
  if (n < 7L) return(NULL)
  design <- designs[[as.character(n)]]
  triples <- design$triples
  test_index <- design$test_index
  sums <- function(scores) {
    rowSums(matrix(scores[common][triples], nrow = nrow(triples)))
  }
  a_sum <- sums(a)
  b_sum <- sums(b)
  reference_difference <- a_sum - b_sum
  test_a <- matrix(a_sum[test_index], nrow = nrow(test_index))
  test_b <- matrix(b_sum[test_index], nrow = nrow(test_index))
  agreement <- function(delta) (1 + sign(delta) * sign(reference_difference)) / 2

  # One uniformly chosen test trio assesses both grants. With independently
  # drawn test trios, every ordered pair of eligible trios is equally likely.
  shared <- rowMeans(agreement(test_a - test_b))
  independent <- numeric(nrow(test_index))
  for (j in seq_len(ncol(test_b)))
    independent <- independent + rowMeans(agreement(test_a - test_b[, j]))
  independent <- independent / ncol(test_b)
  summarize <- function(keep, gap) {
    data.frame(gap = gap, ref_splits = length(keep),
               tied_ref_splits = sum(reference_difference == 0),
               qualifying_ref_splits = sum(keep),
               shared = if (any(keep)) mean(shared[keep]) else NA_real_,
               independent = if (any(keep)) mean(independent[keep]) else NA_real_)
  }
  rbind(summarize(reference_difference != 0, "all nonzero reference gaps"),
        summarize(abs(reference_difference) == 1, "one third of a grade point"))
}

panel_results <- function(d) {
  stopifnot(!anyDuplicated(d[c("proposal_id", "reviewer_id")]))
  ids <- sort(unique(d$proposal_id))
  voters <- sort(unique(d$reviewer_id))
  observed <- matrix(NA_real_, length(ids), length(voters))
  observed[cbind(match(d$proposal_id, ids), match(d$reviewer_id, voters))] <-
    d$score_higher_better
  pairs <- combn(seq_along(ids), 2)
  results <- lapply(seq_len(ncol(pairs)), function(i) {
    pair_results(observed[pairs[1, i], ], observed[pairs[2, i], ])
  })
  results <- do.call(rbind, results)
  by_gap <- split(results, results$gap)
  do.call(rbind, lapply(by_gap, function(result) {
    eligible <- result$qualifying_ref_splits > 0
    data.frame(panel_id = d$panel_id[1], reference_gap = result$gap[1],
      panel_pairs = ncol(pairs), pairs_with_seven_common_voters = nrow(result),
      pairs_contributing = sum(eligible),
      eligible_ref_splits = sum(result$ref_splits),
      tied_ref_splits = sum(result$tied_ref_splits),
      qualifying_ref_splits = sum(result$qualifying_ref_splits),
      shared_trio_agreement = mean(result$shared[eligible]),
      independent_trios_agreement = mean(result$independent[eligible]))
  }))
}
agreement <- do.call(rbind, lapply(split(mint, mint$panel_id), panel_results))
write.csv(agreement, "audit/snsf_three_vote_sensitivity.csv", row.names = FALSE)
