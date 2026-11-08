# SNSF vote data

Rachel Heyard's workbook records panel votes from two 2020 competitions. The April MINT Project Funding call covers all 353 evaluated applications, with nine panel-member positions per section. The February Postdoc.Mobility call records the 79 applications selected for panel discussion from 181 submissions. Members of each fellowship panel scored these applications without seeing one another’s votes. Each section or panel had a separate funding line. [Data and licence](https://doi.org/10.5281/zenodo.4531160) · [Study, sections 3.1–3.2](https://arxiv.org/html/2102.09958) · [Authors' reproducible supplement](https://snsf-data.github.io/ERpaper-online-supplement/)

| Scheme | Panels | Rated proposals | Recorded votes | Votes per proposal | Missing votes | Funding field |
|---|---:|---:|---:|---:|---:|---|
| Project Funding, MINT | 4 | 353 | 2,838 | 5–9 | 339 blank | 114 funded |
| Postdoc.Mobility | 5 | 79 | 1,623 | 13–29 | 10 blank and 1 explicit conflict | Unavailable |

The complete per-panel audit includes grade counts, missingness, graph connectivity and the number of applications scored by each voter. In MINT section 2 one member scored only 19 of 92 proposals. A blank means a missing vote with unspecified cause. The explicit conflict is coded `coi` in the Medicine panel. [Computed panel counts](snsf_panels.csv)

## Reproduction

Run `Rscript --vanilla scripts/snsf_prepare.R` from the repository root with the `readxl`, `digest` and `igraph` packages installed. The archived record fixes the workbook version. The script verifies its depositor-supplied MD5 and the SHA-256 digest I computed.

| Source | Value |
|---|---|
| Creator | Rachel Heyard, Swiss National Science Foundation |
| Record date | 10 February 2021 |
| DOI | 10.5281/zenodo.4531160 |
| Licence | CC BY 4.0 |
| Source file | individual_votes.xlsx |
| MD5 | 7180009e55d14c77ac27a1dc72ec8fea |
| SHA-256 | 626aa376c3a167d3f364cbaf6742451a9a5c30810790bda2675f384a071f4486 |

`data/derived/snsf_ratings.csv` has one row per observed proposal–voter assessment. The `panel_id` is the original sheet name. Both `proposal_id` and `reviewer_id` include that name because local identifiers restart across sheets. Each sheet forms one connected proposal–voter graph. Cross-panel reviewer identity is unavailable. The file preserves `grade` and gives its order in `score_higher_better` (D = 1, C = 2, BC = 3, B = 4, AB = 5, A = 6). The authors' reported four MINT mean proposal scores and four mean scores for the highest-rated 30% all reproduce to their printed precision. [Table 3](https://arxiv.org/html/2102.09958#S3.T3)

`funded` repeats the proposal-level award flag for MINT. Count distinct applications when summarising awards. The paper used a hypothetical 30% funding rate for its ranking illustration. The workbook gives actual decisions on 30, 31, 28 and 25 proposals in sections 1–4 respectively.

## Interpretation for comparison

MINT supports an analysis of rank precision within each section across its full pool. The common ranked quantity can be expressed as within-section percentile position. Each section supplies a single vote scale. Criterion-level information requires another source.

The fellowship sample supports a comparison conditional on selection for discussion and offers an illustration of range restriction. Several lower grade categories are empty. In Social Sciences 245 of 250 votes are AB or B. The workbook cannot identify precision in the whole fellowship applicant pool or estimate grade thresholds outside the observed range.

Panel members score many of the same applications. A model of conditional precision should preserve this shared reviewer structure. Comparable review-count scenarios can be estimated by selecting subsets of the recorded panel votes with explicit treatment of absences. Such an exercise describes the same panel and deliberative context. Generalisation to an entirely new panel requires additional assumptions. Actual awards can describe the historical funding line and panel context. Accuracy against future research outcomes requires independent follow-up.

## Three-vote agreement in the original panels

Run `Rscript --vanilla scripts/snsf_three_vote_sensitivity.R` after the workbook preparation. Within each MINT section, the calculation enumerates all unordered proposal pairs with at least seven panelists who scored both proposals. Three common voters give a reference order by their mean grade. Every allowable reference trio receives equal weight within the pair. Tied reference means contribute to the reported tie count. The agreement calculation uses reference splits that distinguish the two proposals.

The comparison uses only voters outside the reference trio. Among the remaining four to six eligible voters, the first assignment draws one trio for both proposals. The second draws two trios independently from the same available voters. The independently drawn test trios may share members. I enumerate all test assignments, give ties half credit, average agreement within each pair, then weight eligible pairs equally. The output records denominators, reference ties and coverage for each section. Several pairs can share proposals, reviewers and reference splits, so the comparison reports exact descriptive averages over these panels. [Sensitivity output](snsf_three_vote_sensitivity.csv)

Across sections, shared-trio agreement with the held-out reference ranges from 89.2% to 90.7% for nonzero reference differences. Under independent trios it ranges from 89.2% to 90.6%. Restricting to the smallest nonzero reference difference (one third of a point on the six-grade scale), the corresponding ranges are 79.7–81.1% and 79.8–81.0%. Every within-section difference between assignments is below 0.13 percentage points. Grades use the source authors' six-point numeric coding for these mean-score comparisons.

The reference has three votes and carries measurement error. Its observed grade difference has a different interpretation from a specified difference on the latent scale. Reviewer exchangeability in this exercise is confined to members of the observed section with votes on both proposals. Shared deliberation, reviewer absences, and restricting eligible pairs to those with seven overlapping votes may affect the agreement estimates. These data describe reproducibility of reported judgements and can inform discussion of lottery rules. Decisions about an acceptable error rate or fair eligibility criteria require a policy judgement.
