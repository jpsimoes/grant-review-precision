# Comparative ordering probabilities under the common three-rating task.
library(ggplot2)
source("R/tgi_precision.R")
d <- read.csv("results/ordering_curve.csv")
pools <- c("NIH", "AIBS", paste0("mint_section", 1:4))
d <- subset(d, pool %in% pools & percentile >= .05 - 1e-6 & percentile <= .95 + 1e-6)
d$panel <- factor(d$pool, pools, c("NIH · preliminary reviews", "AIBS · assigned reviews",
                                    paste("SNSF MINT · section", 1:4)))
d$source <- ifelse(startsWith(d$pool, "mint_"), "SNSF MINT", d$pool)
source_colours <- c(NIH = "#005A88", AIBS = "#A34716", "SNSF MINT" = "#176747")
d$gap_label <- factor(d$gap, c(.25, .5, 1), c("0.25 SD", "0.5 SD", "1 SD"))
primary <- subset(d, gap == .5)
fig <- ggplot(d, aes(x = percentile, y = correct)) +
  geom_ribbon(data = primary, aes(ymin = lo_two_way, ymax = hi_two_way, fill = source),
              alpha = .18, show.legend = FALSE) +
  geom_line(aes(colour = source, linetype = gap_label, linewidth = gap_label)) +
  facet_wrap(vars(panel), ncol = 2) +
  scale_colour_manual(values = source_colours, guide = "none") +
  scale_fill_manual(values = source_colours, guide = "none") +
  scale_linetype_manual(name = "Proposal gap", values = c("dotted", "solid", "longdash")) +
  scale_linewidth_manual(name = "Proposal gap", values = c(.6, 1, .65)) +
  guides(linetype = guide_legend(override.aes = list(colour = "#29342F"))) +
  scale_x_continuous(breaks = c(.1,.5,.9), labels = c("10","50","90")) +
  scale_y_continuous(breaks = c(.5,.75,1), labels = c("50%","75%","100%")) +
  coord_cartesian(ylim = c(.495,1.005)) +
  labs(title = "How often do ratings rank the two proposals correctly?",
       subtitle = "Each proposal receives three ratings. Shading shows the 95% interval\nfor the half-SD gap.",
       x = "Percentile of the pair midpoint within each proposal pool",
       y = "Probability of a correct ordering") +
  tgi_theme(12.5) +
  theme(
    plot.title.position = "plot",
    plot.title = element_text(size = 16, face = "bold", colour = "#172E29", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 11.5, lineheight = 1.04, colour = "#364840"),
    strip.background = element_rect(fill = "#F4F5F2", colour = NA),
    strip.text = element_text(size = 11.8, hjust = 0, face = "bold", margin = margin(4, 4, 4, 4)),
    panel.border = element_rect(fill = NA, colour = "#BAC3BF", linewidth = .35),
    panel.spacing = grid::unit(3.8, "mm"),
    legend.position = "top", legend.justification = "left", legend.box.just = "left",
    legend.margin = margin(2, 0, 4, 0), legend.key.width = grid::unit(10, "mm"),
    legend.text = element_text(size = 12), legend.title = element_text(size = 12),
    axis.title = element_text(size = 12), plot.margin = margin(7, 8, 5, 7, "pt")
  )

dir.create("figures", showWarnings = FALSE)
ggsave("figures/figure2.png", fig, width = 6.6, height = 6.7, units = "in", dpi = 280,
       bg = "white")
ggsave("figures/figure2.pdf", fig, width = 6.6, height = 6.7, units = "in",
       device = grDevices::cairo_pdf, bg = "white")
