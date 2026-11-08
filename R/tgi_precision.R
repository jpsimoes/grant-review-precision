# Adapted from the TGI-SR+ project's analysis/tgi_sr_irt.R.
# Source revision, original sections and assumptions are in docs/tgi-reuse.md.

# Fisher information for a single administration of the criteria in a
# unidimensional, locally independent graded response model. The caller supplies
# the range of theta supported by the data and the fitted model's orientation.
tgi_grm_profile <- function(model, theta) {
  if (!methods::is(model, "SingleGroupClass") ||
      mirt::extract.mirt(model, "nfact") != 1L ||
      !all(mirt::extract.mirt(model, "itemtype") == "graded")) {
    stop("Supply a single-group, unidimensional graded response model.")
  }
  if (!is.numeric(theta) || !length(theta) || any(!is.finite(theta)) ||
      is.unsorted(theta, strictly = TRUE)) {
    stop("Supply a finite, strictly increasing theta grid.")
  }
  grid <- matrix(theta, ncol = 1L)
  items <- mirt::extract.mirt(model, "itemnames")
  item_curves <- lapply(seq_along(items), function(i) {
    item <- mirt::extract.item(model, i)
    data.frame(theta = theta, criterion = items[i],
               information = as.numeric(mirt::iteminfo(item, Theta = grid)))
  })
  information <- as.numeric(mirt::testinfo(model, Theta = grid))
  if (any(!is.finite(information) | information < 0)) {
    stop("Information is numerically undefined on the supplied grid.")
  }
  list(
    criterion = do.call(rbind, item_curves),
    scale = data.frame(
      theta = theta, information = information,
      conditional_se = 1 / sqrt(information),
      expected_sum = as.numeric(mirt::expected.test(model, Theta = grid, mins = TRUE))
    )
  )
}

# Adapted from TGI-SR+'s theme_pub() with explicit namespaces so callers can
# use the theme independently of the model or the rest of the TGI pipeline.
tgi_theme <- function(base_size = 10) {
  ggplot2::theme_bw(base_size = base_size, base_family = "sans") +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "grey92", linewidth = 0.3),
      panel.border = ggplot2::element_rect(colour = "grey30", fill = NA, linewidth = 0.4),
      strip.background = ggplot2::element_rect(fill = "grey95", colour = "grey30", linewidth = 0.4),
      strip.text = ggplot2::element_text(size = base_size, face = "plain"),
      axis.text = ggplot2::element_text(size = base_size - 1, colour = "grey20"),
      axis.title = ggplot2::element_text(size = base_size, colour = "grey20"),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = base_size),
      legend.text = ggplot2::element_text(size = base_size - 1),
      legend.key.height = grid::unit(3, "mm"),
      legend.key.width = grid::unit(6, "mm"),
      plot.margin = ggplot2::margin(2, 4, 2, 2, "mm"),
      plot.tag = ggplot2::element_text(size = base_size + 2, face = "bold")
    )
}
