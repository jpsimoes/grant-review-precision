source("R/figure_theme.R")
library(ggplot2)

curve <- read.csv("results/criteria_curves.csv")
curve$dataset <- factor(curve$dataset, levels = c("NIH", "AIBS"))
curve$criterion <- factor(curve$criterion,
                          levels = c("approach", "significance", "innovation", "investigator"),
                          labels = c("Approach", "Significance", "Innovation", "Investigator"))
source_labels <- c(NIH = "NIH R01", AIBS = "AIBS biomedical")
ends <- subset(curve, abs(percentile - .9) < 1e-8)
graph <- ggplot(curve, aes(percentile * 100, information, group = dataset)) +
  geom_ribbon(aes(ymin = lower, ymax = upper, fill = dataset),
              alpha = .19, colour = NA, show.legend = FALSE) +
  geom_line(aes(colour = dataset), linewidth = 1) +
  geom_point(data = ends, aes(colour = dataset, shape = dataset), size = 2.5) +
  facet_wrap(vars(criterion), ncol = 2) +
  scale_colour_manual(NULL, values = study_colours, labels = source_labels) +
  scale_fill_manual(NULL, values = study_colours) +
  scale_shape_manual(NULL, values = c(NIH = 16, AIBS = 17), labels = source_labels) +
  scale_x_continuous(breaks = c(10, 50, 90), expand = expansion(mult = .04)) +
  scale_y_continuous(breaks = seq(0, .6, .2), limits = c(0, NA),
                     expand = expansion(mult = c(0, .07))) +
  labs(title = "How well does each criterion distinguish proposals?",
       subtitle = "Higher lines mean more precision from one rating at that position.\nShading shows 95% intervals.",
       x = "Percentile of overall appraisal within each proposal pool",
       y = "Information from one rating") +
  study_figure_theme()

dir.create("figures", showWarnings = FALSE)
ggsave("figures/figure2.png", graph, width = 6.6, height = 5.7, dpi = 280, bg = study_paper)
ggsave("figures/figure2.pdf", graph, width = 6.6, height = 5.7, device = cairo_pdf, bg = study_paper)
