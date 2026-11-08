# How the grant-review analysis works

Figure 1 asks how often three ratings per proposal would correctly order two applications separated by a specified difference in underlying appraisal. Figure 2 estimates how much a single US criterion rating tells us about the overall appraisal reviewers share. [Study design](design.md) · [Article](../article/article.md)

## Data and reference pools

| Source | Unit of calibration | Reviewers | Ratings available |
| --- | --- | --- | --- |
| NIH | One pooled sample of 2,076 R01 proposals from 200 scientific review groups | 4,555 | 5,802 preliminary reviews on a 1–9 scale, with four complete criteria shared with AIBS |
| AIBS | One pooled sample of 72 biomedical proposals from three review cycles | 26 | 216 reviews, three per proposal, on a 1–5 scale in tenths, with overall and criterion ratings |
| SNSF Project Funding (MINT) | Four sections, fitted separately, covering all 353 evaluated proposals | 9 voter slots per section | 2,838 individual six-grade panel votes |
| SNSF Postdoc.Mobility | Five panels, fitted separately, covering 79 of the 181 submitted proposals | 14–29 voter slots per panel | 1,623 individual six-grade panel votes on applications selected for discussion |

The Swiss files identify voter slots within each panel. US counts refer to distinct reviewer IDs in each sample. The original records and their attribution are available from [NIH study materials](https://doi.org/10.17605/OSF.IO/4D6RX), [AIBS data](https://doi.org/10.6084/m9.figshare.12728087) and [SNSF data](https://doi.org/10.5281/zenodo.4531160).

Percentiles and standard deviations refer to each pool separately. Equating a half-SD gap across these programmes in absolute terms would need an external anchor. The NIH file pools several years and lacks identifiers for the meetings at which funding lines were set. [US data and assignments](../audit/us_data.md) · [Swiss votes and selection](../audit/snsf_compatibility.md)

## The probability of ordering two proposals correctly

Let $\theta_i$ denote the repeatable overall appraisal of proposal $i$ in its pool. Both $\theta_i$ and the rating-specific residual $\epsilon_{ij}$ have standard normal distributions. The continuous judgement underlying reviewer $j$'s overall grade is

$$
Z_{ij}=\sqrt{\rho}\,\theta_i+\sqrt{1-\rho}\,\epsilon_{ij}.
$$

Pool-specific thresholds translate the judgement into grades. We orient higher values toward more favourable reviews and return scores to the original scale for reporting. Each proposal has weight one, split among its reviews. Inverse-normal cumulative grade frequencies give the thresholds. A bivariate ordinal likelihood estimates $\rho$, weighting each multiply rated proposal equally across its distinct-reviewer pairs. The 75 NIH singletons contribute to the thresholds only. [Model and code](../R/ordering.R) · [Two-step polychoric estimation](https://doi.org/10.1007/BF02296207)

The estimated correlation $\rho$ of two underlying judgements of the same proposal is 0.350 in NIH, 0.361 in AIBS and 0.871–0.928 in MINT. The model assumes common thresholds, constant residual variance and conditionally independent ratings within a pool. Its accuracy curve therefore changes shape with grade use. It averages over the historical reviewer mix. In NIH, 3,542 of 4,555 reviewers appear only once and the assignment graph has 973 disconnected components. In MINT, a shared panel discussion can contribute to the fitted proposal effect. [Assignment audit](../audit/us_assignments.csv)

For midpoint percentile $u$, place the proposals at $\Phi^{-1}(u)\pm\delta/2$, with a primary separation $\delta$ of 0.5 within-pool SD and alternatives of 0.25 and 1. Convolve the fitted native-grade probabilities three times for each proposal. Comparing all pairs of sums gives the probability of a correct order, with ties split equally. Native grades preserve the score spacing used when averaging, including the observed AIBS tenths. [Calculation](ordering.md) · [Ordering curves](../results/ordering_curve.csv)

## What each criterion measures

We pair a criterion grade with a *different* reviewer's overall grade on the same proposal. If the continuous criterion response has correlation $\lambda_c$ with $\theta$, conditionally independent errors across these two reviewers imply a cross-reviewer criterion–overall correlation of $\lambda_c\sqrt{\rho}$. Dividing its ordinal estimate by $\sqrt{\rho}$ gives the criterion loading. Each criterion retains its own thresholds. [Calibration code](../R/criteria.R)

With category probabilities $p_k(\theta)$, one rating supplies Fisher information $\sum_k [p'_k(\theta)]^2/p_k(\theta)$. A higher value means that a small shift in overall appraisal changes the grade probabilities more detectably at that position. Figure 2 covers the 10th–90th percentiles. Adding the four curves would require modelling dependence among one reviewer's criterion scores. [Criterion methods](criteria.md) · [Information and loadings](../results/criteria_curves.csv)

## What can we learn about dimensionality?

The scalar $\theta$ represents the repeatable component of overall grades. A reviewer could reach that grade by weighing several qualities. Swiss reviewers recorded one overall vote per application, so these files support tests of vote agreement and prediction. Assessing the number of distinct substantive criteria would require separate criterion ratings.

The US records permit a direct check. If overall appraisal accounts for all repeatable criterion signal, the correlation of two criteria scored by different reviewers should equal the product of their overall-appraisal loadings. This applies even when both reviewers score the same criterion. As a post hoc diagnostic, we checked all ten distinct criterion combinations and refitted them in 999 whole-proposal bootstrap samples. Intervals allow for testing all ten residuals within each dataset.

For the NIH investigator criterion, the observed cross-reviewer correlation was 0.391. Its association with overall grades predicted 0.254, leaving a residual of 0.137 (simultaneous 95% interval 0.093–0.181). Innovation had excess agreement in both NIH (0.089, interval 0.057–0.121) and AIBS (0.178, interval 0.041–0.315). The overall grade misses some repeatable distinctions reviewers make about individual criteria. The residuals can also reflect differences in reviewer assignment or grade use. They do not identify a particular number of additional factors. Figure 2 therefore quantifies information specifically about *overall appraisal*. [Dimensionality check](dimensionality.md) · [All observed and predicted correlations](../results/dimensionality_residuals.csv)

## How well does the model predict another review?

Five-fold validation holds out whole proposals. From each eligible held-out proposal, we draw three reviews and predict each grade from the other two. The table gives root mean squared error on the native scale. A reviewer may appear in both training and test folds on different applications. [Prediction code](../R/ordering.R) · [All 11 pools](../results/ordering_diagnostics.csv)

| Pool | Scored predictions | Model | Training-pool mean | Mean of two grades |
| --- | ---: | ---: | ---: | ---: |
| NIH | 4,899 of 4,899 | 1.535 | 1.688 | 1.674 |
| AIBS | 203 of 216 | 0.747 | 0.815 | 0.785 |
| Four SNSF MINT sections, range of section values | 1,059 of 1,059 | 0.521–0.542 | 1.113–1.234 | 0.526–0.552 |

The MINT model improves on the two-grade average by less than 0.01 grade in every section. The average has lower error in two of five fellowship panels. In AIBS, 13 targets required a predictor grade absent from the training fold and were excluded throughout. Among the most favourable quarter of predictions, AIBS expected 18.7% best grades and observed 11.5% (52 targets). NIH expected 11.3% and observed 10.2%. These checks evaluate score prediction. The latent ordering itself is unobserved. [Upper-range calibration](../results/ordering_calibration.csv)

In MINT, for pairs with at least seven shared voters, three gave a reference order and other voters provided a comparison. At the smallest nonzero reference gap (one third of a grade), agreement was about 80% within each original panel. In the US samples, one reviewer's criterion grade of 2 or better, versus a less favourable grade, helped predict another reviewer's overall grade of 2 or better. Against the training-set prevalence, the largest Brier-score gains were 0.0047 for NIH approach and 0.0145 for AIBS innovation. [Swiss voting check](../audit/snsf_three_vote_sensitivity.csv) · [Criterion predictions](../results/criteria_prediction_checks.csv)

## Uncertainty, cutoffs and the funding decision

For the ordering curves, 400 positive exponential reweightings of proposals give cluster intervals. A further 400 fits reweight reviewers as well, normalising rating and pair weights within each proposal. Figure 1 shows the latter pointwise 95% intervals for the half-SD gap. Figure 2 uses 999 whole-proposal bootstrap samples. For six criterion contrasts at the 90th percentile, within-dataset simultaneous intervals put the NIH approach–innovation difference at 0.214 (95% interval 0.138–0.289). All six AIBS intervals include zero. Omitting one AIBS cycle can change the leading criterion. [Contrasts](../results/criteria_contrasts.csv) · [Influence checks](../results/criteria_aibs_influence.csv)

For each gap, we search the upper half of the pool for the last downward crossing of a target (65% to 95%, every five points). Both proposals must lie inside the pool's expected extreme plotting positions. A stricter check requires at least five expected applications beyond each end of the pair. In MINT section 3, estimated accuracy crosses 80% at the 96.7th percentile. Only 53% of proposal reweightings yield a terminal crossing, and the stricter rule excludes that location. The table gives both crossing frequency and location intervals conditional on a crossing. [Boundary estimates](../results/ordering_boundaries.csv)

A lottery decision starts with actual applicants' scores, reviewer assignments and the budget. Translating the curves into eligibility would require uncertainty estimates for those applicants' ranks, a distinction the funder considers worth acting on, and an acceptable risk of reversing it. An independent reassessment of close calls could test recurrence outside the original panel. [SNSF analysis of rank uncertainty at a funding line](https://doi.org/10.1080/2330443X.2022.2086190)

## Reproduction

From the repository root, run `Rscript --vanilla scripts/reproduce.R`. It retrieves the public source files, checks their digests, rebuilds the analyses and runs numerical checks against enumeration, finite differences and known simulated parameters. [Reproduction guide](../docs/reproduction.md) · [TGI code provenance](../docs/tgi-reuse.md)

Please cite the study and the source datasets you use. The original article, figures and documentation use CC BY 4.0. The study code uses the MIT licence. [Preferred citation](../CITATION.cff) · [Rights and attribution](../LICENSE.md)
