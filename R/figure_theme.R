# The essay site uses Newsreader, warm paper and fine horizontal rules.
# The display face follows the site's serif fallback order for offline rendering.
source("R/tgi_precision.R")

study_paper <- "#FAF7F2"
study_colours <- c(NIH = "#005A88", AIBS = "#A34716", "SNSF MINT" = "#2F5D44")

study_figure_theme <- function() {
  available <- systemfonts::system_fonts()$family
  typefaces <- c("Newsreader", "Iowan Old Style", "Georgia")
  serif <- c(typefaces[typefaces %in% available], "serif")[1]
  ink <- "#211D17"
  muted <- "#6E655A"
  rule <- "#E6DFD4"
  tgi_theme(12.5) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = ink),
      plot.background = ggplot2::element_rect(fill = study_paper, colour = NA),
      panel.background = ggplot2::element_rect(fill = study_paper, colour = NA),
      panel.border = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(colour = rule, linewidth = .35),
      axis.line.x = ggplot2::element_line(colour = "#B8AD9E", linewidth = .35),
      axis.ticks = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = 11, colour = muted),
      axis.title = ggplot2::element_text(size = 12, colour = ink),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 5)),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(family = serif, face = "bold", size = 13,
                                         colour = "#2F5D44", hjust = 0,
                                         margin = ggplot2::margin(t = 3, b = 4)),
      panel.spacing = grid::unit(4.2, "mm"),
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(family = serif, face = "plain", size = 18,
                                         lineheight = .97, margin = ggplot2::margin(b = 5)),
      plot.subtitle = ggplot2::element_text(size = 11.5, colour = muted, lineheight = 1.04),
      legend.position = "top", legend.justification = "left", legend.box.just = "left",
      legend.background = ggplot2::element_blank(), legend.key = ggplot2::element_blank(),
      legend.key.width = grid::unit(10, "mm"),
      legend.margin = ggplot2::margin(3, 0, 6, 0),
      legend.title = ggplot2::element_text(size = 12), legend.text = ggplot2::element_text(size = 12),
      plot.margin = ggplot2::margin(8, 9, 7, 8)
    )
}
