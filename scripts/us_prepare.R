# Run from the repository root with Rscript --vanilla scripts/us_prepare.R.
source("scripts/us_fetch.R")
dir.create("audit", showWarnings = FALSE)
dir.create("data/derived", recursive = TRUE, showWarnings = FALSE)

read_reviews <- function(dataset) {
  container <- new.env(parent = emptyenv())
  loaded <- load(file.path("data/raw", paste0(dataset, ".rda")), envir = container)
  stopifnot(identical(loaded, dataset))
  raw <- container[[dataset]]
  nih <- dataset == "NIH"
  d <- data.frame(
    dataset = dataset,
    proposal_id = as.character(raw$ID),
    reviewer_id = as.character(raw$RevID),
    review_group = if (nih) as.character(raw$SRG) else NA_character_,
    integrated_review_group = if (nih) as.character(raw$IRG) else NA_character_,
    administering_institute = if (nih) as.character(raw$AdminOrg) else NA_character_,
    cycle = if (nih) NA_integer_ else raw$Year,
    proposal_type = as.character(raw$PropType),
    overall = raw$Score,
    significance = if (nih) raw$Significance else raw$Signif,
    investigator = if (nih) raw$Investigator else raw$Investig,
    innovation = raw$Innovation,
    approach = raw$Approach,
    environment = if (nih) raw$Environment else NA_real_,
    impact = if (nih) NA_real_ else raw$Impact
  )
  required <- c("overall", "significance", "investigator", "innovation", "approach")
  stopifnot(!anyNA(d[c("proposal_id", "reviewer_id", required)]))
  stopifnot(!anyDuplicated(d[c("proposal_id", "reviewer_id")]))
  scores <- unlist(d[c(required, "environment", "impact")], use.names = FALSE)
  scores <- scores[!is.na(scores)]
  step <- if (nih) 1 else 0.1
  stopifnot(all(scores >= 1 & scores <= if (nih) 9 else 5))
  stopifnot(all(abs(scores / step - round(scores / step)) < 1e-7))
  means <- ave(d$overall, d$proposal_id)
  stopifnot(isTRUE(all.equal(means, raw$ScoreAvg, tolerance = 1e-8)))
  if (nih) {
    stopifnot(all(is.na(raw$ScoreFinal) == (raw$ScoreFinalChar == "ND")))
  } else {
    stopifnot(all(is.na(d$impact) == (d$cycle != 2014)))
  }
  d
}

reviews <- setNames(lapply(sources$dataset, read_reviews), sources$dataset)
write.csv(do.call(rbind, reviews), "data/derived/us_reviews.csv", row.names = FALSE, na = "")
write.csv(sources, "audit/us_sources.csv", row.names = FALSE)

assignment_audit <- function(d) {
  counts <- table(d$proposal_id)
  reviewer_counts <- table(d$reviewer_id)
  edges <- data.frame(paste0("p:", d$proposal_id), paste0("r:", d$reviewer_id))
  graph <- igraph::graph_from_data_frame(edges, directed = FALSE)
  labels <- igraph::components(graph)$membership
  component_sizes <- table(labels[startsWith(names(labels), "p:")])
  data.frame(
    dataset = d$dataset[1], reviews = nrow(d), proposals = length(counts),
    reviewers = length(reviewer_counts), min_reviews = min(counts),
    median_reviews = median(counts), max_reviews = max(counts),
    proposals_with_3_reviews = sum(counts == 3),
    reviewers_with_one_proposal = sum(reviewer_counts == 1),
    components = length(component_sizes),
    single_proposal_components = sum(component_sizes == 1),
    largest_component_proposals = max(component_sizes)
  )
}
write.csv(do.call(rbind, lapply(reviews, assignment_audit)),
          "audit/us_assignments.csv", row.names = FALSE)

score_audit <- function(d) {
  variables <- c("overall", "significance", "investigator", "innovation", "approach",
                 if (d$dataset[1] == "NIH") "environment" else "impact")
  do.call(rbind, lapply(variables, function(variable) {
    scores <- d[[variable]]
    observed <- scores[!is.na(scores)]
    data.frame(dataset = d$dataset[1], variable = variable,
               observed = length(observed), missing = sum(is.na(scores)),
               min = min(observed), max = max(observed),
               observed_categories = length(unique(observed)),
               best_category_n = sum(observed == 1),
               integer_scores_n = sum(abs(observed - round(observed)) < 1e-8))
  }))
}
write.csv(do.call(rbind, lapply(reviews, score_audit)),
          "audit/us_scales.csv", row.names = FALSE)

count_assignments <- function(d) {
  counts <- table(as.integer(table(d$proposal_id)))
  data.frame(dataset = d$dataset[1], reviews_per_proposal = as.integer(names(counts)),
             proposals = as.integer(counts))
}
write.csv(do.call(rbind, lapply(reviews, count_assignments)),
          "audit/us_review_counts.csv", row.names = FALSE)

strata_counts <- function(d, columns, stratum) {
  labels <- do.call(paste, c(d[columns], sep = " / "))
  counts <- vapply(split(d$proposal_id, labels), function(x) length(unique(x)), integer(1))
  ranked <- data.frame(dataset = d$dataset[1], stratum = stratum, groups = length(counts),
                       smallest = min(counts), median = median(counts), largest = max(counts))
  ranked
}
strata <- rbind(strata_counts(reviews$NIH, "review_group", "scientific review group"),
                strata_counts(reviews$NIH, "integrated_review_group", "integrated review group"),
                strata_counts(reviews$NIH, "administering_institute", "administering institute"),
                strata_counts(reviews$AIBS, "cycle", "year"),
                strata_counts(reviews$AIBS, c("cycle", "proposal_type"), "year and type"))
write.csv(strata, "audit/us_strata.csv", row.names = FALSE)
