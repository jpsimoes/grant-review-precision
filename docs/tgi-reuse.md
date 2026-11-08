# TGI-SR+ code attribution

The item information, expected score, total information and publication theme in
`R/tgi_precision.R` adapt code from the **TGI-SR+ adult IRT analysis**,
`analysis/tgi_sr_irt.R`, from the project *Item Response Theory Analysis of
DSM-5-TR and ICD-11 Prolonged Grief Disorder Items in 5924 Bereaved Adults*.
The SHA-256 of the working source file on 8 November 2026 was
`6e23bd5a2383326b0b57aa2c2d285be63674893a6ef54fb614911dbccb9c2a94`.
This digest identifies the specific file containing the adapted code.

| Source lines | Reuse |
| --- | --- |
| 33–42 | The study entry point `scripts/reproduce.R` resolves its project directory from the script path, including spaces encoded by Rscript. |
| 182–200 | The ggplot2 theme in `tgi_theme()` preserves the source styling and qualifies all package functions. |
| 721–723, 1529–1532 | The expected-score grid in `ordering_location()` uses ordinal-probit response probabilities and native grade values to translate latent locations into expected overall grades. |
| 721–723, 812–818, 1510–1513 | The information function in `tgi_grm_profile()` evaluates item and total information and expected sum score on a caller-supplied grid. |

The GRM adapter requires one latent dimension, a single group and conditionally
independent ordinal item responses. Its information curves refer to one
administration of the criteria with fixed calibration parameters. The conditional
standard error uses the inverse square root of total Fisher information. The
expected sum follows the category codes passed to the fitted model.

A reviewer-adjusted analysis has to propagate uncertainty about the reviewers
and the calibration into proposal comparisons. With several scores from each
reviewer, the dependence between those scores can change how much information
they jointly supply. The calling analysis defines the supported grid, score
direction and comparison margin separately for each review design. Estimated
rank uncertainty and decisions at a budget boundary require their own models.

Run `Rscript scripts/check_tgi_precision.R` from the repository root to check
the adaptation with two synthetic graded items. The check compares the code
against the closed-form information and expected score for known logistic
response curves, including items with different numbers of categories and
different minimum scores.
