# Checks score orientation, one-rating information and cross-review identification.
source("R/ordering.R")
source("R/criteria.R")
cuts <- qnorm(c(.1, .3, .75))
px <- diff(c(0, pnorm(cuts), 1))
stopifnot(max(abs(criterion_rectangles(px, px, .4) - ordering_joint(cuts, .4))) < 1e-10)
l <- .6
prob <- function(t) diff(pnorm((c(-Inf, cuts, Inf) - l * t) / sqrt(1 - l^2)))
for (t in c(-1.2, 0, 1.2)) {
  h <- 1e-5
  numerical <- sum(((prob(t + h) - prob(t - h)) / (2 * h))^2 / prob(t))
  stopifnot(abs(numerical - criterion_information(cuts, l, t)) < 1e-8)
}
# Recovery fixture with a large shared review-specific impression. Reusing the
# *same* reviewer's overall grade would exaggerate the target cross-review loading.
set.seed(90631)
N <- 6000L
i <- rep(seq_len(N), each = 3L)
t <- rnorm(N)[i]
halo <- rnorm(length(i))
overall <- sqrt(.4) * t + sqrt(.6) * halo
criterion <- l * t + .7 * halo + sqrt(1 - l^2 - .7^2) * rnorm(length(i))
grade <- function(x) 5L - findInterval(x, cuts)
d <- data.frame(proposal_id = i, overall = grade(overall), criterion = grade(criterion))
d$score <- -d$overall
values <- sort(unique(d$score))
tables <- list(overall = list(counts = ordering_counts(d, values)$counts, scores = values),
               criterion = criterion_tables(d, "criterion"))
fit <- criterion_calibration(tables, rep(1, N), c(-1, 0, 1))
stopifnot(abs(fit$loading[1] - l) < .045, abs(fit$anchor_rho[1] - .4) < .035)
cat("Cross-review loading in the halo fixture:", round(fit$loading[1], 3),
    "(target 0.60). Rectangle and Fisher information checks passed.\n")
