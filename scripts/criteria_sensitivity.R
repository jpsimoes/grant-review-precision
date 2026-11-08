source("R/ordering.R")
source("R/criteria.R")
d <- read.csv("data/derived/us_reviews.csv", colClasses = c(proposal_id = "character",
                                                            reviewer_id = "character"))
criteria <- c("approach", "significance", "innovation", "investigator")
aibs <- subset(d, dataset == "AIBS")
influence <- function(exclude) {
  ids <- unique(aibs[[exclude]])
  res <- do.call(rbind, lapply(ids, function(value) {
    reduced <- aibs[aibs[[exclude]] != value, ]
    tables <- criterion_dataset_tables(reduced, criteria)
    fit <- criterion_calibration(tables, rep(1, nrow(tables$overall$counts)), qnorm(.9))
    fit$highest <- fit$information == max(fit$information)
    fit
  }))
  do.call(rbind, lapply(split(res, res$criterion), function(c) {
    data.frame(omitted_unit = exclude, units = length(ids), criterion = c$criterion[1],
               valid = sum(is.finite(c$information)), min_info = min(c$information, na.rm = TRUE),
               max_info = max(c$information, na.rm = TRUE), highest_n = sum(c$highest, na.rm = TRUE))
  }))
}
write.csv(rbind(influence("reviewer_id"), influence("cycle")),
          "results/criteria_aibs_influence.csv", row.names = FALSE)

# Five folds hold out whole proposals. Convert the fitted ordinal bivariate law
# to two conditional predictions for another reviewer's overall grade <= 2.
set.seed(12812)
cross_validate <- function(data) {
  ids <- sort(unique(data$proposal_id))
  fold_id <- sample(rep(1:5, length.out = length(ids)))
  names(fold_id) <- ids
  predictions <- lapply(1:5, function(fold) {
    held <- fold_id[data$proposal_id] == fold
    train <- data[!held, ]
    test <- data[held, ]
    training_weight <- 1 / ave(rep(1, nrow(train)), train$proposal_id, FUN = sum)
    p_overall <- weighted.mean(train$overall <= 2, training_weight)
    tables <- criterion_dataset_tables(train, criteria)
    all_weights <- rep(1, nrow(tables$overall$counts))
    rows <- seq_len(nrow(test))
    pairs <- merge(data.frame(id = test$proposal_id, left = rows),
                   data.frame(id = test$proposal_id, right = rows), by = "id")
    pairs <- pairs[pairs$left != pairs$right, ]
    outcomes <- test$overall[pairs$right] <= 2
    do.call(rbind, lapply(criteria, function(key) {
      p_criterion <- weighted.mean(train[[key]] <= 2, training_weight)
      fit <- criterion_pair_fit(tables[[key]], all_weights)
      joint_good <- pbivnorm::pbivnorm(qnorm(p_criterion), qnorm(p_overall), fit$rho)
      probability <- ifelse(test[[key]][pairs$left] <= 2,
                            joint_good / p_criterion,
                            (p_overall - joint_good) / (1 - p_criterion))
      agg <- aggregate(data.frame(model_brier = (outcomes - probability)^2,
                                  baseline_brier = (outcomes - p_overall)^2),
                       by = list(proposal = pairs$id), FUN = mean)
      agg$criterion <- key
      agg
    }))
  })
  by_proposal <- do.call(rbind, predictions)
  res <- aggregate(by_proposal[c("model_brier", "baseline_brier")],
                   by = list(criterion = by_proposal$criterion), FUN = mean)
  transform(res, dataset = data$dataset[1], proposals = length(unique(by_proposal$proposal)),
            brier_gain = baseline_brier - model_brier)
}
write.csv(do.call(rbind, lapply(split(d, d$dataset), cross_validate)),
          "results/criteria_prediction_checks.csv", row.names = FALSE)
