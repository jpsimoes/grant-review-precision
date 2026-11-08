# Can grant scores tell us when to use a lottery?

Jorge Piano Simões · November 2026

How often would three reviews per proposal correctly order two applications that differ by half a standard deviation in their pool's underlying appraisal? At the 80th percentile, the estimated probability is 66.5% in the NIH R01 sample, 67.0% in the AIBS sample and 84.7–91.4% across four SNSF project-funding sections. The five discussion-selected Swiss fellowship panels give estimates of 64–67%. Panel context, selection and the spread of proposals affect what those comparisons mean.

The strongest candidate for an upper boundary at 80% ordering accuracy was in Swiss project-funding section 3, at the 96.7th percentile. Only 53% of proposal resamples yielded a terminal crossing, and it lay beyond the stricter tail-support range. The full results show what happens as the proposal gap, required accuracy and supported range vary. [Read the article](article/article.md) · [Ordering estimates](results/ordering_curve.csv) · [Candidate boundaries](results/ordering_boundaries.csv)

The [technical README](methods/README.md) is the companion methods section. It explains how the overall appraisal is identified, what a one-factor model predicts about agreement on the criteria, how well the model predicts withheld reviews, and which conclusions the data support.

## Reproduce the study

Install R with Cairo support and the packages listed in the [reproduction guide](docs/reproduction.md). From the project directory, run

```sh
Rscript --vanilla scripts/reproduce.R
```

This downloads the three pinned public inputs, verifies their checksums, builds the review records and runs the analyses and checks. The outputs include two figures, nine aggregate result tables and seven audit tables. A clean rerun reproduced all 18 derived, audit and results CSVs byte for byte and both figure rasters pixel for pixel. For the PDF article, install Pandoc 3, Python 3 and ReportLab 4, then run `python3 scripts/render_article.py`. To rebuild the companion ZIP, run `python3 scripts/package_release.py`.

## Read the analysis

- The [study design](methods/design.md) defines the comparison, reference pools and primary gap. The [ordering methods](methods/ordering.md) cover the native rating scales, resampling, prediction checks and support for an upper boundary.
- The [criterion methods](methods/criteria.md) anchor each US criterion to a different reviewer's overall judgement of the same proposal. [Figure 1](figures/figure1.png) shows the chance of ordering a pair correctly. [Figure 2](figures/figure2.png) shows criterion information. The [dimensionality check](methods/dimensionality.md) shows where reviewers agree on individual features beyond what their overall grades predict.
- The [NIH and AIBS audit](audit/us_data.md) and [SNSF audit](audit/snsf_compatibility.md) document selection, missingness, assignments and vote coding. The [software environment](docs/environment.csv) records the analysis package versions.
- The [TGI-SR+ adaptation record](docs/tgi-reuse.md) identifies the original source by digest, lists the adapted routines and explains their assumptions. The overall grant-rating model, cross-reviewer calibration and ordering analysis were developed for these review designs.

## Public data and credit

The scripts retrieve review-level data from the original public distributors. Please cite the sources used in your analysis.

- **NIH.** Erosheva and colleagues' preliminary R01 reviews, distributed with ShinyItemAnalysis. [Source study](https://doi.org/10.1126/sciadv.aaz4868) · [Original project](https://doi.org/10.17605/OSF.IO/4D6RX) · [Data dictionary](https://search.r-project.org/CRAN/refmans/ShinyItemAnalysis/html/NIH.html)
- **AIBS.** Stephen Gallo's biomedical review data, distributed here through the pinned ShinyItemAnalysis release. Figshare lists CC BY 4.0 for the source dataset. [Data record](https://doi.org/10.6084/m9.figshare.12728087)
- **SNSF.** Rachel Heyard's public record of individual votes for two funding schemes, released under CC BY 4.0. [Data record](https://doi.org/10.5281/zenodo.4531160) · [Source study](https://doi.org/10.1080/2330443X.2022.2086190)

Please cite the study as **Simões, J. P. (2026). *Can grant scores tell us when to use a lottery?*** The [citation file](CITATION.cff) supplies machine-readable author and title metadata. The original article, figures and study documentation carry CC BY 4.0, and the study code carries the MIT licence. [Rights and attribution](LICENSE.md) · [Software licence](LICENSE-CODE.txt)
