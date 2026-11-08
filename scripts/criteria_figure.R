source("R/tgi_precision.R")
library(ggplot2)

curve <- read.csv("results/criteria_curves.csv")
curve$dataset <- factor(curve$dataset, levels = c("NIH", "AIBS"))
curve$criterion <- factor(curve$criterion,
                          levels = c("approach", "significance", "innovation", "investigator"),
                          labels = c("Approach", "Significance", "Innovation", "Investigator"))
source_colours <- c(NIH = "#005A88", AIBS = "#A34716")
source_labels <- c(NIH = "NIH R01", AIBS = "AIBS biomedical")
ends <- subset(curve, abs(percentile - .9) < 1e-8)
graph <- ggplot(curve, aes(percentile * 100, information, group = dataset)) +
  geom_ribbon(aes(ymin = lower, ymax = upper, fill = dataset),
              alpha = .19, colour = NA, show.legend = FALSE) +
  geom_line(aes(colour = dataset), linewidth = 1) +
  geom_point(data = ends, aes(colour = dataset, shape = dataset), size = 2.5) +
  facet_wrap(vars(criterion), ncol = 2) +
  scale_colour_manual(NULL, values = source_colours, labels = source_labels) +
  scale_fill_manual(NULL, values = source_colours) +
  scale_shape_manual(NULL, values = c(NIH = 16, AIBS = 17), labels = source_labels) +
  scale_x_continuous(breaks = c(10, 50, 90), expand = expansion(mult = .04)) +
  scale_y_continuous(breaks = seq(0, .6, .2), limits = c(0, NA),
                     expand = expansion(mult = c(0, .07))) +
  labs(title = "How well does each criterion distinguish proposals?",
       subtitle = "Higher lines mean more precision from one rating at that position.\nShading shows 95% intervals.",
       x = "Percentile of overall appraisal within each proposal pool",
       y = "Information from one rating") +
  tgi_theme(base_size = 12.5) +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(size = 16.5, face = "bold", colour = "#172E29", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 11.5, lineheight = 1.04, colour = "#364840"),
    strip.background = element_rect(fill = "#F4F5F2", colour = NA),
    strip.text = element_text(size = 12.5, face = "bold", hjust = 0, margin = margin(4, 4, 4, 4)),
    panel.border = element_rect(fill = NA, colour = "#BAC3BF", linewidth = .35),
    panel.spacing = grid::unit(3.4, "mm"),
    axis.title = element_text(size = 12),
    legend.position = "top", legend.justification = "left",
    legend.box.just = "left", legend.margin = margin(2, 0, 4, 0),
    legend.key.width = grid::unit(8, "mm"), legend.text = element_text(size = 12.5),
    plot.margin = margin(7, 8, 5, 7, "pt")
  )
dir.create("figures", showWarnings = FALSE)
ggsave("figures/figure1.png", graph, width = 6.6, height = 5.7, dpi = 280, bg = "white")
ggsave("figures/figure1.pdf", graph, width = 6.6, height = 5.7, device = cairo_pdf, bg = "white")
