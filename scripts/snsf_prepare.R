# Run from the study root with Rscript --vanilla scripts/snsf_prepare.R
# Source: Rachel Heyard (2021), doi:10.5281/zenodo.4531160, CC BY 4.0.
# Requires readxl, digest and igraph.
options(stringsAsFactors = FALSE)
for (path in c("data/raw", "data/derived", "audit"))
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

source_url <- "https://zenodo.org/records/4531160/files/individual_votes.xlsx"
raw_file <- "data/raw/snsf_individual_votes.xlsx"
sha256 <- "626aa376c3a167d3f364cbaf6742451a9a5c30810790bda2675f384a071f4486"
verify_file <- function(path) {
  stopifnot(unname(tools::md5sum(path)) == "7180009e55d14c77ac27a1dc72ec8fea",
            digest::digest(file = path, algo = "sha256") == sha256)
}
if (!file.exists(raw_file)) {
  temporary <- tempfile(tmpdir = dirname(raw_file))
  tryCatch({
    download.file(source_url, temporary, mode = "wb", quiet = TRUE)
    verify_file(temporary)
    stopifnot(file.rename(temporary, raw_file))
  }, finally = unlink(temporary))
}
verify_file(raw_file)

panel_names <- c(pm_stem = "STEM", pm_lsm = "Medicine", pm_lsb = "Biology",
                 pm_hsss = "Social Sciences", pm_hssh = "Humanities",
                 mint_section1 = "MINT 1", mint_section2 = "MINT 2",
                 mint_section3 = "MINT 3", mint_section4 = "MINT 4")
grade_order <- c("D", "C", "BC", "B", "AB", "A")
stopifnot(setequal(readxl::excel_sheets(raw_file), names(panel_names)))

read_panel <- function(panel) {
  tab <- as.data.frame(readxl::read_excel(raw_file, sheet = panel, col_types = "text"))
  voters <- grep("^voter[0-9]+$", names(tab), value = TRUE)
  project <- startsWith(panel, "mint_")
  expected <- c("proposal", voters, if (project) "Fund")
  stopifnot(setequal(names(tab), expected), !anyNA(tab$proposal),
            !anyDuplicated(tab$proposal), length(voters) >= 2L)
  awards <- if (project) {
    stopifnot(all(tab$Fund %in% c("0", "1")))
    as.integer(tab$Fund)
  } else rep(NA_integer_, nrow(tab))

  # Vectorization follows Excel column order, with proposals varying fastest.
  grade <- as.vector(as.matrix(tab[voters]))
  blank <- is.na(grade)
  coi <- !blank & grade == "coi"
  observed <- !(blank | coi)
  stopifnot(all(grade[observed] %in% grade_order))
  rows <- data.frame(
    dataset = "SNSF",
    scheme = if (project) "Project Funding" else "Postdoc.Mobility",
    panel_id = panel,
    proposal_id = paste(panel, rep(tab$proposal, times = length(voters)), sep = "/"),
    reviewer_id = paste(panel, rep(voters, each = nrow(tab)), sep = "/"),
    grade = grade, score_higher_better = match(grade, grade_order),
    funded = rep(awards, times = length(voters)))
  ratings <- rows[observed, , drop = FALSE]
  stopifnot(!anyDuplicated(ratings[c("proposal_id", "reviewer_id")]))
  coverage <- table(ratings$proposal_id)
  reviewer_coverage <- table(ratings$reviewer_id)
  stopifnot(length(coverage) == nrow(tab), length(reviewer_coverage) == length(voters))
  graph <- igraph::graph_from_data_frame(ratings[c("proposal_id", "reviewer_id")],
                                         directed = FALSE)
  audit <- data.frame(panel_id = panel, label = panel_names[[panel]],
    scheme = ratings$scheme[1], proposals = nrow(tab), panel_voter_slots = length(voters),
    votes = nrow(ratings), blank = sum(blank), explicit_coi = sum(coi),
    r_min = min(coverage), r_median = as.numeric(median(coverage)), r_max = max(coverage),
    proposals_per_voter_min = min(reviewer_coverage),
    proposals_per_voter_max = max(reviewer_coverage),
    assignment_components = igraph::components(graph)$no,
    funded = if (project) sum(awards) else NA_integer_)
  for (g in grade_order) audit[[paste0("grade_", g)]] <- sum(ratings$grade == g)
  list(ratings = ratings, audit = audit)
}
panels <- lapply(names(panel_names), read_panel)
ratings <- do.call(rbind, lapply(panels, "[[", "ratings"))
audit <- do.call(rbind, lapply(panels, "[[", "audit"))
stopifnot(nrow(ratings) == 4461L, sum(audit$proposals) == 432L,
          all(audit$assignment_components == 1L),
          all(audit$votes + audit$blank + audit$explicit_coi ==
                audit$proposals * audit$panel_voter_slots),
          sum(audit$funded, na.rm = TRUE) == 114L)
# Reproduce both columns of published mean proposal scores in Heyard et al.,
# Table 3. This checks the grade direction, eligibility and proposal weighting.
mint <- ratings[ratings$scheme == "Project Funding", ]
proposal_means <- aggregate(score_higher_better ~ panel_id + proposal_id, mint, mean)
by_section <- split(proposal_means$score_higher_better, proposal_means$panel_id)
top_mean <- function(x) mean(head(sort(x, decreasing = TRUE), round(.30 * length(x))))
stopifnot(all(round(vapply(by_section, mean, numeric(1)), 2) == c(3.84, 3.81, 3.97, 3.73)),
          all(round(vapply(by_section, top_mean, numeric(1)), 2) == c(5.01, 5.02, 5.24, 5.04)))
write.csv(ratings, "data/derived/snsf_ratings.csv", row.names = FALSE, na = "")
write.csv(audit, "audit/snsf_panels.csv", row.names = FALSE, na = "")
message("Verified ", nrow(ratings), " votes on ", sum(audit$proposals),
        " proposals across ", nrow(audit), " panels.")
