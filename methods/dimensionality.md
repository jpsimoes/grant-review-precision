# How much agreement can one overall-appraisal factor account for?

The four US criteria include approach or feasibility, significance, investigator and innovation. Two reviewers can agree about an investigator's strengths even when their overall judgements of a proposal differ. This post hoc diagnostic asks whether the proposal effect inferred from repeated overall grades accounts for the relationships that persist between criterion ratings made by *different* reviewers. All ten unique criterion pairs are examined in each US dataset, including the four pairs where both reviewers score the same criterion.

## Model implication

Let each continuous response underlying an ordinal grade have marginal variance one. Suppose each measure `c` has a loading `a_c` on a single standardized proposal effect. Assume common thresholds and loadings within a pool and independent errors between reviewers conditional on that effect. The same reviewer can have a shared impression across scores. For grades from two different reviewers of the same proposal, the model predicts the following correlations, where `O` denotes the overall grade.

    r_OO = a_O²
    r_cO = a_c × a_O
    r_cd = a_c × a_d = r_cO × r_dO / r_OO

The last equality is testable because the four criterion–overall correlations and repeated-overall correlation determine the predicted values for all ten criterion pairs. The comparison uses the original ordinal categories and the two-step polychoric estimator from the [criterion calibration](criteria.md). The general idea of comparing associations across both traits and methods dates to [Campbell and Fiske (1959)](https://pubmed.ncbi.nlm.nih.gov/13634291/).

## Estimation and uncertainty

Each pool has 15 fitted correlations among the five measures. For each pair of measures we estimate both sets of grade thresholds using proposal-weighted marginal frequencies. We then estimate their correlation by maximizing the weighted log likelihood of the ordinal cells observed across different reviewers. For a proposal with `m` reviews, each of its `m(m−1)` ordered reviewer pairs gets weight `1/[m(m−1)]`. This includes both reviewer orientations and makes the result symmetric in the two measures. NIH contributes 11,092 ordered pairs from 2,001 multiply reviewed proposals, with 75 additional singletons informing the thresholds. All 72 AIBS proposals contribute three reviews, or 432 ordered pairs.

The diagnostic is the observed cross-review polychoric correlation minus its predicted value. For the same criterion on both sides, a positive value means that reviewers agree about that feature more than their agreement through overall appraisal predicts. For different criteria, sign and magnitude indicate the direction and size of departure. The correlation unit applies to the continuous responses underlying the recorded grades.

We resampled whole proposals 999 times per dataset. Each replicate refit all thresholds, all 15 correlations and the resulting ten residuals. For each residual we estimated its bootstrap standard deviation. Within each joint draw, we centered every residual on its full-sample estimate, divided by its bootstrap SD and retained the largest absolute value among the ten. The 95th percentile of those maxima supplies the common multiplier for approximate simultaneous 95% intervals within that pool. All 999 draws had a positive identified overall anchor and finite admissible overall loadings in both samples. The intervals condition on the sampled competitions. In a separate influence analysis we removed each of the 26 AIBS reviewers in turn. In NIH we partitioned the 4,555 assessors into ten disjoint groups, cycling through reviewers in order of decreasing workload, then removed one group at a time. Each omission removed 578–582 of the 5,802 reviews. The omission ranges describe sensitivity to these reviewer sets.

## Results and interpretation

| Dataset and criterion pair | Cross-review correlation | One-factor prediction | Difference (simultaneous 95% interval) |
| --- | ---: | ---: | ---: |
| NIH investigator with investigator | .391 | .254 | .137 (.093 to .181) |
| NIH innovation with innovation | .253 | .165 | .089 (.057 to .121) |
| NIH significance with significance | .235 | .206 | .029 (.004 to .054) |
| NIH significance with approach | .233 | .247 | −.014 (−.025 to −.002) |
| AIBS innovation with innovation | .432 | .254 | .178 (.041 to .315) |

The table lists every interval excluding zero. The [full results](../results/dimensionality_residuals.csv) give all 20 comparisons. The six NIH cross-criterion point residuals were small, with absolute values below .019. Every NIH reviewer omission preserved the positive investigator residual (.122 to .158) and innovation residual (.080 to .097). In AIBS the innovation residual ranged from .145 to .213 across the 26 reviewer omissions. AIBS significance also had a positive point estimate of .151, with an interval from −.005 to .307.

The strict single-factor account misses reproducible patterns in these ratings. Criterion-specific proposal features are one explanation. Differences among review settings or reviewer assignments, or failures of the assumed ordinal response model, could also contribute. The residuals do not identify how many substantive traits exist. Figure 2 describes how informative each criterion is about the repeatable component of overall appraisal. These results help explain how even a criterion with modest information about that target can carry another kind of agreement. Adding information across all four criteria would require a model for their joint dependence.

Figure 1 is fitted directly to repeated *overall* grades and requires distinct assumptions about independent reviewer errors, exchangeability, the distribution of appraisal and grading thresholds. The ten residuals above test consequences of extending that scalar appraisal to explain *all criterion agreement*. An error in that extension does not change the definition of the overall-ordering estimand. The Swiss sources supply one overall vote per reviewer–proposal assignment. Held-out vote prediction and comparisons of disjoint voter groups can check reproducibility there. Establishing the content dimensions underlying a Swiss vote would require measurements of multiple content domains.

## Reproduction

```sh
Rscript --vanilla scripts/dimensionality_checks.R
Rscript --vanilla scripts/dimensionality_analysis.R
```

The seeded simulation uses 6,000 proposals, three reviewers per proposal and a shared review-specific impression. Under one factor the estimated excess innovation correlation was .009 (target zero). Adding an independent innovation-specific proposal effect gave .235 (target .2304). The analysis writes the aggregate CSV from the prepared US reviews. It uses three bootstrap workers on platforms supporting process forks and one on Windows.
