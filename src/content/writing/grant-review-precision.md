---
title: "Can grant scores tell us when to use a lottery?"
author: "Jorge Piano Simões"
date: 2026-11-08
description: "A comparison of public US and Swiss grant reviews asks how precisely three ratings distinguish competitive proposals, and what a funder would need to know before drawing lots."
pdf: "/files/grant-review-precision/grant-review-precision.pdf"
---

At school I was the kid who wanted to know when, exactly, I was going to need trigonometry.\* My maths teachers had plenty of examples of the uses of mathematics. CD players (I am that old), tuning a guitar, working out which route the bin lorry should take. I could see that somebody needed maths to do all of that. I still wanted to know when it would be my turn.

One application they could safely have left off the list was designing the rules for a grant lottery. Even I would have found that a fairly niche answer. Yet here I am, spending some of my own time trying to work out what half a point on a grant application is worth.

In one Horizon Europe pilot, the strongest proposals go straight through to a second stage. Then comes a group close to the invitation line. Their scores can span at most half a point, and a draw determines their order. I like how concrete that rule is. Imagine being the applicant just outside the draw. What could the funder tell you about how reliably its reviewers can distinguish projects half a point apart? [European Commission pilot rules](https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/support/faq/107102).

I couldn’t answer that for the European call. I could ask a related question of three public sources where several people judged the same application. If two proposals differ by a specified amount in the appraisal they tend to receive, how often would three ratings apiece put them in the right order? And does that get harder among the strongest proposals, where a funder might actually consider drawing lots?

| Review setting | Proposals | Ratings | Reviewers | What reviewers scored |
| --- | ---: | ---: | --- | --- |
| US National Institutes of Health (NIH) | 2,076 | 5,802 | 4,555 | Preliminary impact and criteria, 1–9 |
| American Institute of Biological Sciences (AIBS) review | 72 | 216 | 26 | Scientific merit and criteria, 1–5 in tenths |
| Swiss National Science Foundation (SNSF), MINT | 353 | 2,838 | 9 per section | Panel votes, six grades, four sections |
| SNSF Postdoc.Mobility, discussed applications | 79 | 1,623 | 14–29 per panel | Panel votes, six grades, five panels |

The NIH data span 200 scientific review groups. In the smaller AIBS programme, every proposal went to three reviewers. The Swiss project-funding data cover all the applications evaluated in four sections with separate budgets. The Swiss fellowship data offer a particularly interesting wrinkle. Only 79 of 181 applications reached the discussion that produced the recorded votes. [NIH data and sampling](https://doi.org/10.1126/sciadv.aaz4868) · [AIBS data](https://doi.org/10.6084/m9.figshare.12728087) · [SNSF data](https://doi.org/10.5281/zenodo.4531160).

## What can three reviews settle?

By “right order” I mean something fairly modest. Some applications tend to elicit more favourable overall grades across reviewers. Call that tendency their underlying appraisal. The repeated grades tell us something about how much appraisals vary across applications and how much two reviewers of the same application can disagree. An unfunded idea that would have transformed the field could quite easily have received three poor reviews. These records would tell us precisely nothing about that missed opportunity.

For each pool I fitted a model that connects underlying appraisal to the grades reviewers used. It assumes a bell-shaped spread of appraisals and the same amount of reviewer noise along that scale. Under those assumptions the spacing between grade boundaries can make a difference easier to detect in one part of the pool than in another. I took two hypothetical applications half a standard deviation apart on that pool’s appraisal scale. I could put the pair near the middle or towards the top. At each position I calculated the chance that three ratings per proposal would give the better-appraised one the better mean grade. The calculation counts every possible combination of grades and splits ties equally. A half standard deviation always means half the spread of underlying appraisals *in that pool*. The half point in the European rule is written on a score sheet. Translating between those two units would take ratings from the call itself.

[![Ordering accuracy stays near two-thirds in NIH and AIBS for a half-standard-deviation gap. The four Swiss project-funding sections have higher estimates that vary across percentiles.](/files/grant-review-precision/figure1.png)](/files/grant-review-precision/figure1.png)

*Figure 1. Chance that the higher-appraised proposal gets the better three-rating average. The dotted, solid and dashed curves correspond to gaps of a quarter, half and one standard deviation. Shading gives pointwise 95% intervals for the half-SD curve from reweighting proposals and reviewers.*

Start at the 80th percentile, with a fairly competitive pair of applications. Three ratings apiece put the better-appraised proposal first **66.5% of the time at NIH and 67.0% at AIBS**. The approximate uncertainty intervals were 65–68% and 61–73%, respectively. Move the same pair to the middle of either distribution and the answer is still about two in three. At NIH, changing the *distance* between the competitors matters much more. At the 80th percentile, a quarter-SD gap gives 58% accuracy. A full SD gives 80%.

The estimates for all four Swiss project-funding sections were higher on the same half-SD task, ranging from **85% to 91%** at the 80th percentile. There’s a tempting headline in there about the Swiss having cracked peer review. The fellowship panels make it hard to write. Among applications selected for fellowship discussion, the five estimates were 64–67%. By then the pool had already narrowed. Erosheva and colleagues showed how selecting the strongest applicants can sharply reduce measured agreement. Here the people scoring and the stage of review changed too. Three votes from one competition needn’t buy the same precision in another. [Erosheva, Martinková and Lee](https://doi.org/10.1111/rssa.12681).

The Swiss voters also sat on the same panel. They could share information about an application that a new panel might never hear. I checked how often one trio’s ordering agreed with that of other voters from the same project-funding section. Even when the reference trio’s means differed by the smallest possible nonzero amount, just a third of a grade, the other votes agreed about 80% of the time. That gives me some confidence about consistency *inside those panels*. I’d want to see a second, independently convened panel before making claims about what would happen on a fresh review.

## What went into that one number?

There’s a fairly large assumption hiding in the phrase “underlying appraisal”. A proposal can ask a wonderful question and have a shaky plan for answering it. Another can have a beautifully designed study of a question you’ve heard answered before. Why should one number capture both? The US reviewers scored significance, investigator, innovation and approach or feasibility as well as giving an overall grade. That gives us a way to ask what the overall number leaves out.

I first asked how much each criterion tells us about the overall appraisal reviewers share. The trick is to take the criterion score from one person and the overall score from *someone else* who reviewed the same proposal. Otherwise, one enthusiastic reviewer who gives high marks across the board can make a criterion look remarkably informative.

[![Four panels compare NIH and AIBS criterion ratings. Near the top of the NIH pool, approach supplies the most information about overall appraisal. The AIBS estimates have wider uncertainty bands.](/files/grant-review-precision/figure2.png)](/files/grant-review-precision/figure2.png)

*Figure 2. A higher curve means that one criterion rating distinguishes nearby overall appraisals more precisely at that position in its pool. Shading gives pointwise 95% intervals from resampling proposals.*

At the NIH 90th percentile, approach gave more than twice as much information about overall appraisal as innovation (0.39 versus 0.18). It also exceeded investigator and significance, each about 0.23, even allowing for all six comparisons. In AIBS, innovation came first by point estimate. With only 72 proposals, the data were consistent with either ordering for every pair of criteria. Leaving out one review cycle could change which came first.

There’s a second question we can ask. Suppose one shared appraisal really did explain everything on which different reviewers agree. Knowing how closely each criterion tracks the overall grade then predicts how closely two reviewers should agree on *the same criterion*. Extra agreement about innovation, for example, would suggest that two people can see something similar in a proposal’s originality even when their innovation scores track the overall grade only modestly.

That is what I found. At NIH the estimated correlation between two reviewers scoring the investigator was 0.39. A single shared appraisal predicted 0.25. Reviewers also agreed more than predicted about innovation. At AIBS the clearest discrepancy was innovation again (0.43 observed, 0.25 predicted). These differences stood up when I accounted for all ten criterion comparisons within each dataset. Losing the innovation scores would therefore lose some agreement that the overall grades failed to capture. Who reviews which proposals can also influence that agreement. If the funder cares about originality, that distinction matters.

The Swiss voters recorded just one overall grade each. They give us repeated looks at the verdict and no comparable way to tell whether the voters agreed about originality, feasibility or both. For the overall model I also tried a more ordinary test. I set proposals aside, used two of their reviews to predict a third and compared the predictions with a simple average. In the four Swiss project-funding sections the model gained less than a hundredth of a grade over that average. In AIBS it was optimistic at the favourable end. Of the 52 third reviews with the most favourable predicted grades, the model expected 19% to receive the best grade. Only 12% did.

## Who goes into the draw?

Suppose a funder is willing to follow a ranking if it gets a half-SD comparison right at least 70% of the time. In both US samples the estimates were already below that requirement at the median and stayed below through the 95th percentile. A funder willing to accept 65% would follow the ranking throughout that same range. Neither choice singles out a particular top score at which the panel should put down its pencils.

The most promising-looking boundary was in Swiss project-funding section 3. Its half-SD curve eventually fell below 80% at the 96.7th percentile, an expected grade of 5.89 out of 6. How often would I have found a boundary if a slightly different set of applications had arrived? Only 53% of resamples gave a downward crossing that persisted to the end of the range. Requiring at least five expected applications beyond each end of the pair put the crossing outside the range we could examine. In section 2 an apparent boundary near the 85th percentile disappeared when the curve climbed back above target. Even the six grades on the Swiss ballot mattered here. A pair that straddles a grade boundary can be easier to distinguish than one that falls within a grade.

If I were advising the panel with one invitation left, I’d start with the decision in front of it. How small a difference between two projects would it actually want to act on? How often would it accept reversing their order? Heyard and colleagues approached the problem from the budget line itself, identifying Swiss applications whose plausible ranks fell on either side of the last award. The two questions fit together. We can ask how much the review process usually resolves, then look at the actual contenders to see where the uncertainty falls. [SNSF ranking and lottery study](https://doi.org/10.1080/2330443X.2022.2086190).

What I’d most like to see in a pilot is an independent second look at a sample of close calls, with the criterion scores kept. Count how often the order repeats, how many applicants change sides at the actual budget line, and whether an extra review settles enough cases to justify asking someone to write it. Those are numbers I could explain to the applicant who missed the draw by half a point.

## Data and methods

The [technical README](https://github.com/jpsimoes/grant-review-precision/blob/main/methods/README.md) gives the model, checks, runnable code and source data. The package credits the expected-score calculation and plotting code I adapted from an earlier item response theory project on the TGI-SR+. Original article and figures © 2026 Jorge Piano Simões, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Please cite the article and the datasets you use.

\* The answer to my school question was *eighteen years later*, when I found myself fitting cosine waves to wearable data to model circadian rhythms. I’ll give that one to my maths teachers.
