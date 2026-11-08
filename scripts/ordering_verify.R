# From the study root: Rscript --vanilla scripts/ordering_verify.R
source("R/ordering.R")
# For a median cut, P(both higher) = 1/4 + asin(rho)/(2*pi). P=1/3 yields rho=.5.
binary <- matrix(c(2, 0, 1, 1, 0, 2), byrow=TRUE, ncol=2)
fixture <- ordering_fit(binary, c(1,2))
stopifnot(abs(fixture$rho - .5) < 2e-6, abs(fixture$cuts) < 1e-12)
# Direct enumeration for an irregularly spaced scale verifies the FFT, native
# scoring and the tie convention independently of the FFT implementation.
fixture <- list(rho=.53, scores=c(1, 2.2, 3), cuts=c(-.6, .95))
q <- .83
gap <- .5
prob <- ordering_category_probs(fixture, qnorm(q) + c(-gap, gap)/2)
triple <- as.matrix(expand.grid(rep(list(seq_along(fixture$scores)), 3L)))
total <- rowSums(matrix(round(10*fixture$scores[triple]), ncol=3))
p_triple <- function(p) apply(matrix(p[triple], ncol=3), 1, prod)
joint <- outer(p_triple(prob[2,]), p_triple(prob[1,]))
difference <- outer(total, total, "-")
direct <- sum(joint * ((difference > 0) + .5*(difference == 0)))
stopifnot(abs(direct - ordering_curve(fixture, q, gap)) < 1e-12,
          max(abs(ordering_curve(fixture, c(.1,.5,.9), 0) - .5)) < 1e-12)
curve <- read.csv("results/ordering_curve.csv")
fits <- read.csv("results/ordering_diagnostics.csv")
rho <- fits$rho[match(curve$pool, fits$pool)]
# Optimal comparison of two native continuous three-rating means supplies
# an upper bound before coarsening to grades.
limit <- pnorm(curve$gap * sqrt(3 * rho / (2*(1-rho))))
stopifnot(all(curve$correct > .5 - 1e-10), all(curve$correct <= limit + 1e-9),
          all(curve$lo <= curve$hi), all(curve$lo_two_way <= curve$hi_two_way),
          all(complete.cases(curve)), all(fits$cv_scored <= fits$cv_targets),
          nrow(fits)==11, length(unique(curve$pool))==11)
message("Verified tetrachoric likelihood, exact ordering probabilities and continuous-information bound.")
