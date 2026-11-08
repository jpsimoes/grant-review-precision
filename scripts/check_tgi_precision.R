# Run from the project root with Rscript scripts/check_tgi_precision.R
source("R/tgi_precision.R")

# Supply identified, fixed parameters. Enumerating possible response patterns
# gives mirt each category and preserves the two different score minima.
patterns <- expand.grid(three_categories = 1:3, four_categories = 0:3)
parameters <- mirt::mirt(patterns, 1L, itemtype = "graded", pars = "values",
                         verbose = FALSE)
slopes <- c(1.20, 0.65)
intercepts <- list(c(0.9, -0.65), c(1.2, 0.15, -0.95))
parameters$value[parameters$name == "a1"] <- slopes
for (i in seq_along(intercepts)) {
  item_thresholds <- parameters$item == names(patterns)[i] &
    grepl("^d[0-9]+$", parameters$name)
  parameters$value[item_thresholds] <- intercepts[[i]]
}
parameters$est <- FALSE
model <- mirt::mirt(patterns, 1L, itemtype = "graded", pars = parameters,
                    verbose = FALSE)
theta <- seq(-2.5, 2.5, length.out = 21)
profile <- tgi_grm_profile(model, theta)

# Independent calculation from cumulative logistic probabilities and their
# derivatives. This catches category-order, score-origin and grid mistakes as
# well as any change in the information convention used by the package.
analytic_item <- function(slope, thresholds, scores, theta) {
  cumulative <- plogis(slope * theta + thresholds)
  derivative <- slope * cumulative * (1 - cumulative)
  p <- -diff(c(1, cumulative, 0))
  dp <- -diff(c(0, derivative, 0))
  c(information = sum(dp^2 / p), expected_sum = sum(scores * p))
}
analytic <- lapply(seq_along(slopes), function(i) {
  scores <- sort(unique(patterns[[i]]))
  t(vapply(theta, function(x) analytic_item(slopes[i], intercepts[[i]], scores, x),
           numeric(2)))
})
reference <- Reduce("+", analytic)
for (i in seq_along(analytic)) {
  curve <- subset(profile$criterion, criterion == names(patterns)[i])
  stopifnot(identical(curve$theta, theta),
            max(abs(curve$information - analytic[[i]][, "information"])) < 1e-10)
}
stopifnot(
  max(abs(profile$scale$information - reference[, "information"])) < 1e-10,
  max(abs(profile$scale$expected_sum - reference[, "expected_sum"])) < 1e-10,
  max(abs(profile$scale$conditional_se - 1 / sqrt(reference[, "information"]))) < 1e-10
)
cat("Conditional GRM information, expected score and SE match the analytic fixture.\n")
