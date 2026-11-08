# Recover a one-factor pattern, then add a distinct reproducible criterion feature.
source("R/criteria.R")
source("R/dimensionality.R")
set.seed(220309)
n <- 6000L
proposal <- rep(seq_len(n), each = 3L)
overall_appraisal <- rnorm(n)[proposal]
domain <- rnorm(n)[proposal]
halo <- rnorm(length(proposal))
errors <- matrix(rnorm(length(proposal) * 3L), ncol = 3L)
grade <- function(z) 5L - findInterval(z, qnorm(c(.12, .35, .75, .91)))
for (domain_loading in c(0, .48)) {
  # Two large within-review halo loadings test the cross-review pairing.
  scores <- data.frame(
    proposal_id = proposal, reviewer_id = seq_along(proposal),
    overall = grade(.65 * overall_appraisal + .50 * halo + sqrt(1-.65^2-.50^2) * errors[, 1]),
    approach = grade(.55 * overall_appraisal + .50 * halo + sqrt(1-.55^2-.50^2) * errors[, 2]),
    innovation = grade(.50 * overall_appraisal + .45 * halo + domain_loading * domain +
                         sqrt(1-.50^2-.45^2-domain_loading^2) * errors[, 3])
  )
  tables <- dimension_tables(scores, c("approach", "innovation"))
  fit <- dimension_estimates(tables, rep(1, n))
  domain_entry <- fit$first == "innovation" & fit$second == "innovation"
  truth <- ifelse(domain_entry, domain_loading^2, 0)
  stopifnot(max(abs(fit$residual - truth)) < .05)
  message("Cross-review innovation residual ", round(fit$residual[domain_entry], 3),
          " (target ", round(domain_loading^2, 3), ").")
}
