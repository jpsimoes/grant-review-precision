---
title: "Can grant scores tell us when to use a lottery?"
author: "Jorge Piano Simões"
date: 2026-11-08
description: "A comparison of public US and Swiss grant reviews asks how precisely three ratings distinguish competitive proposals, and what a funder would need to know before drawing lots."
license: "CC BY 4.0"
licenseUrl: "https://creativecommons.org/licenses/by/4.0/"
---

This started as a lazy Sunday project. I wanted to try a small side analysis: could a statistical method I’d used elsewhere tell me anything interesting about how research proposals are scored? Before I had this blog, I would probably have made a few plots, satisfied my curiosity and shelved it. This time, I thought I’d share the question and what I found.

Imagine two scientists applying for money to carry out their research. Reviewers read their proposals and give them scores. One finishes slightly ahead of the other. If there’s only enough money for one, that small difference could decide which project happens. But how much should we trust it? Would different reviewers put the same proposal first?

Take this recently introduced rule in Horizon Europe, the EU’s research and innovation funding programme. In one pilot, the strongest proposals go straight through to a second stage. Then comes a group close to the invitation line. If their scores span at most half a point on the ten-point first-stage scale, a draw determines their order. This lottery decides who gets to the next stage, not who receives the final grant. Imagine being the applicant just outside the draw. What could the funder tell you about how reliably its reviewers can distinguish projects half a point apart? [European Commission pilot rules](https://ec.europa.eu/info/funding-tenders/opportunities/docs/2021-2027/horizon/wp-call/2026-2027/wp-7-digital-industry-and-space_horizon-2026-2027_en.pdf#page=187) · [First-stage scoring](https://ec.europa.eu/info/funding-tenders/opportunities/docs/2021-2027/horizon/wp-call/2026-2027/wp-15-general-annexes_horizon-2026-2027_en.pdf#page=26).

I couldn't answer that for the European call because I couldn't find a publicly available dataset containing its reviewer ratings. But there were public data from reviews for the US National Institutes of Health (NIH), the American Institute of Biological Sciences (AIBS), and the Swiss National Science Foundation (SNSF). In each, several people judged the same application. That gave me a way to explore a related question: how much can a few reviews tell us about the difference between two proposals?

It also gave me an excuse to use item response theory, or IRT. The name isn’t much of an invitation, but the idea is useful: one reviewer’s score is an imperfect guide to the appraisal a proposal would tend to receive across reviewers. IRT models the connection between an underlying characteristic and the answers or ratings we actually see. Here, I wanted to use that way of thinking to ask where a scoring system can distinguish proposals.

## What can multiple reviews settle?

Think of a test on which almost everyone gets full marks. It might tell you who has learnt the basics, but it won’t tell you much about differences among the strongest students. That’s the sort of problem IRT lets us examine: how much a response tells us can depend on where we are on the underlying scale. Could grant scores have a similar problem among the strongest proposals?

There’s an important limit to what I can mean by “strongest” here. Some applications tend to elicit more favourable overall grades across reviewers. Call that tendency their underlying appraisal. The repeated grades tell us something about how much appraisals vary across applications and how much two reviewers of the same application can disagree. An unfunded idea that would have transformed the field could quite easily have received three poor reviews [\[1\]](#notes-and-references). These records would tell us precisely nothing about that missed opportunity.

For each pool I fitted a model that connects underlying appraisal to the grades reviewers used. Then I gave it a small task: Take two hypothetical proposals a fixed distance apart in underlying appraisal, give each three ratings, and see how often their average grades put the better-appraised one first. Move the pair from the middle of the pool towards the top, keeping that distance unchanged. Does telling them apart get harder?

For the main comparison, I used a gap of half a standard deviation (half-SD). A standard deviation measures spread: this gap is half the spread of underlying appraisals *in that pool*. The half point in the European rule is written on a score sheet. Translating between those two units would take ratings from the call itself.

In Figure 1, start with the solid curves. Moving right means comparing proposals further up their pool; a higher curve means the three-rating averages more often put them in the model’s “right order”. The technical README gives the assumptions and calculation details.

![Ordering accuracy stays near two-thirds in NIH and AIBS for a half-standard-deviation gap. The four Swiss project-funding sections have higher estimates that vary across percentiles.](../figures/figure1.png)

*Figure 1. Chance that the higher-appraised proposal gets the better three-rating average. The dotted, solid and dashed curves correspond to gaps of a quarter, half and one standard deviation. Shading gives pointwise 95% intervals for the half-SD curve from reweighting proposals and reviewers.*

The first thing worth noticing is how little the answer changes across the two US pools. Start with a pair centred at the 80th percentile, above roughly four-fifths of its pool, with that half-SD gap. Three ratings apiece put the better-appraised proposal first **66.5% of the time at NIH and 67.0% at AIBS**. The approximate uncertainty intervals were 65–68% and 61–73%, respectively. Move the same pair to the middle of either distribution and the answer is still about two in three. At NIH, changing the *distance* between the competitors matters much more. At the 80th percentile, a quarter-SD gap gives 58% accuracy. A full SD gives 80%.

The estimates for all four Swiss project-funding sections were higher on the same half-SD task, ranging from **85% to 91%** at the 80th percentile. The five fellowship panels gave lower estimates: 64–67%. But these were not like-for-like comparisons. The project-funding data covered all applications in those sections; the fellowship votes covered only 79 of 181 applications, after an initial selection for panel discussion. Think of comparing a whole class with a shortlist of its strongest students: the shortlist may contain much smaller differences to judge. A half-SD gap also means half the spread within each pool, not the same difference across competitions. Erosheva and colleagues showed how selecting the strongest applicants can reduce measured agreement. Different panellists and a different review stage add to the difficulty of comparing the two settings. The lower fellowship estimates therefore don’t, on their own, mean that those reviewers did a worse job. [Erosheva, Martinková and Lee](https://doi.org/10.1111/rssa.12681).

The Swiss voters also sat on the same panel. They could share information about an application that a new panel might never hear. I checked how often one trio’s ordering agreed with that of other voters from the same project-funding section. Even when the reference trio’s means differed by the smallest possible nonzero amount, just a third of a grade, the other votes agreed about 80% of the time. That gives me some confidence about consistency *inside those panels*.

## What went into that one number?

There’s a fairly large assumption hiding in the phrase “underlying appraisal”. A proposal can ask a wonderful question and have a shaky plan for answering it. Another can have a beautifully designed study of a question you’ve heard answered before. Why should one number capture both? The US reviewers scored significance, investigator, innovation and approach or feasibility as well as giving an overall grade. That gave me a way to ask what the overall number leaves out.

This led to the second thing I wanted to explore: what gets lost when we reduce a proposal to one score? Reviewers are asked how sound the methods are, what difference the project might make, and how well placed the applicants are to carry it out. I first asked how much each criterion could tell me about the overall appraisal reviewers share. Here, “information” means how precisely a rating helps distinguish nearby appraisals. The trick is to take the criterion score from one person and the overall score from *someone else* who reviewed the same proposal. Otherwise, one enthusiastic reviewer who gives high marks across the board can make a criterion look remarkably informative.

![Four panels compare NIH and AIBS criterion ratings. Near the top of the NIH pool, approach supplies the most information about overall appraisal. The AIBS estimates have wider uncertainty bands.](../figures/figure2.png)

*Figure 2. A higher curve means that one criterion rating distinguishes nearby overall appraisals more precisely at that position in its pool. Shading gives pointwise 95% intervals from resampling proposals.*

Among highly rated NIH proposals, the score for approach (how the research would be carried out) told me more about the overall appraisal than the score for innovation. At the 90th percentile, it gave more than twice as much information (0.39 versus 0.18). That doesn’t mean a careful plan is twice as valuable as an original idea; it describes how these ratings relate to the overall appraisal in this model. It also exceeded investigator and significance, each about 0.23, even allowing for all six comparisons. In AIBS, innovation came first by point estimate. With only 72 proposals, the data were consistent with either ordering for every pair of criteria. Leaving out one review cycle could change which came first.

I had a second question. Suppose one shared appraisal really did explain everything on which different reviewers agree. Knowing how closely each criterion tracks the overall grade then predicts how closely two reviewers should agree on *the same criterion*. Extra agreement about innovation, for example, would suggest that two people can see something similar in a proposal’s originality even when their innovation scores track the overall grade only modestly.

That is what I found. At NIH the estimated correlation between two reviewers scoring the investigator was 0.39. A single shared appraisal predicted 0.25. Reviewers also agreed more than predicted about innovation. At AIBS the clearest discrepancy was innovation again (0.43 observed, 0.25 predicted). These differences stood up when I accounted for all ten criterion comparisons within each dataset. Losing the innovation scores would therefore lose some agreement that the overall grades failed to capture. Who reviews which proposals can also influence that agreement. If the funder cares about originality, that distinction matters.

The Swiss voters recorded just one overall grade each. They give us repeated looks at the verdict and no comparable way to tell whether the voters agreed about originality, feasibility or both. For the overall model I also tried a more ordinary test. I set proposals aside, used two of their reviews to predict a third and compared the predictions with a simple average. In the four Swiss project-funding sections the model gained less than a hundredth of a grade over that average. In AIBS it was optimistic at the favourable end. Of the 52 third reviews with the most favourable predicted grades, the model expected 19% to receive the best grade. Only 12% did.

## Who goes into the draw?

Suppose a funder is willing to follow a ranking if it gets a half-SD comparison right at least 70% of the time. In both US samples the estimates were already below that requirement at the median and stayed below through the 95th percentile. A funder willing to accept 65% would follow the ranking throughout that same range. Neither choice singles out a particular top score at which the panel should put down its pencils.

For the Swiss project-funding panels, I tried a stricter requirement: get the same comparison right at least 80% of the time. In one section, the model dropped below that target only among the very highest-rated proposals. That looked like a possible place to switch from ranking to a lottery. But when I repeatedly reran the analysis on samples drawn from the same data, only about half produced a drop that lasted. There were also too few applications at that extreme to support a reliable comparison. In another section, performance dipped below 80% and then rose above it again—so there was no single point beyond which ranking stopped meeting the target. I hadn’t found a dependable score at which ranking should give way to a lottery.

That brought me back to the decision behind the numbers. How small a difference between two projects would a funder actually want to act on? How often would it accept reversing their order? Heyard and colleagues approached the problem from the budget line itself, identifying Swiss applications whose plausible ranks fell on either side of the last award. The two questions fit together. We can ask how much the review process usually resolves, then look at the actual contenders to see where the uncertainty falls. [SNSF ranking and lottery study](https://doi.org/10.1080/2330443X.2022.2086190).

I’d still like to see an independent second look at a sample of close calls, with the criterion scores kept. Would another panel put the same proposals first? Would an extra review change who gets funded? Those would be useful checks on what the model suggests. Even for a sample of close calls, a second panel would cost money and take up reviewers’ time.

For this Sunday project, though, the interesting part was what IRT helped me ask. How much of a difference can the scores resolve? Does that change across the scale? And what do we lose when several kinds of judgement become one number? I didn’t come away with a rule for running a lottery. I came away with a better understanding of what these scores can—and can’t—tell us. That seemed worth sharing rather than leaving in a folder.

## Data and methods

The [technical README](https://github.com/jpsimoes/grant-review-precision/blob/main/methods/README.md) on GitHub brings together the data sources, model, analysis code and checks behind this post.

I used Astra in OpenAI Codex, with reasoning effort set to *ultra*, to help write and test the analysis code, make the figures and edit this post.

## Notes and references

\[1\] Katalin Karikó, whose work with Drew Weissman helped lay the groundwork for the mRNA COVID-19 vaccines, recalled spending two years submitting at least one grant application a month without a single success. That doesn’t tell us how often funders miss an important idea. But it does make the distinction worth keeping in mind: predicting which proposals reviewers will like is not the same as predicting which research will matter. Katalin Karikó, interviewed by Sara Frueh for *Issues in Science and Technology*, Fall 2024. [“You Learn More From Failure—When Things Are Not Working Well.”](https://issues.org/interview-katalin-kariko/)
