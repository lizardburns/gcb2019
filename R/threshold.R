# threshold dose

# stats ------------------------------------------------------------------------
# (a) load vs dose by tissue: no difference in loads at death between doses
#  - multiple tissues from same individual => repeated measures
m_load_dose <- lme(
  fixed = log_vload ~ dose + sample_type,
  random = ~ 1 | id,
  data = dloads %>%
    filter(
      dose != "control",
      sample_type %in% c("liver", "kidney", "toeclip")
    )
)
# summary(m_load_dose)

# (b) difference at day 8 by dose (mix of live and dead animals in both treatments but obviously ratio varies by dose): higher inoculum doses give infections a headstart
dloads_pc8 <- dloads %>%
  filter(dose != "control", sample_type == "pc8")

m_load_d8dose <- lm(log_vload ~ dose, data = dloads_pc8)
# summary(m_load_d8dose)

# alive vs dead: individuals have higher loads at death than when alive
# (c) repeated measures on same individuals at day 8 and death using swabs
dloads_repMeas <- dloads %>%
  filter(
    id %in% c(31, 33, 35, 36, 42, 49, 50, 76, 89),
    sample_type %in% c("pc_pm", "pc8")
  )

m_load_time <- lme(fixed = log_vload ~ sample_type,
                   random = ~ 1 | id,
                   data = dloads_repMeas)
# summary(m_load_time)

# (d) tissue samples from midpoint euthanised versus dead: loads are higher in dead animals
# - multiple tissues from same individual => repeated measures
# what data were collected?
# dloads %>%
#   filter(
#     dose == "low",
#     sample_type %in% c("liver", "kidney", "toeclip")
#     ) %>%
#   count(dose, euth, sample_type, name = "count")

dloads_euth <- dloads %>%
  filter(
    dose == "low",
    sample_type %in% c("liver", "kidney", "toeclip")
  )

m_load_euth <- lme(fixed = log_vload ~ euth,
                   random = ~ 1 | id,
                   data = dloads_euth)
# summary(m_load_euth)

# plot figS8 -------------------------------------------------------------------
# visualise threshold
# (a) load vs dose by tissue: no difference in loads at death between doses
tissue_names <- list(
  "liver" = "Liver",
  "kidney" = "Kidney",
  "toeclip" = "Toeclip"
)

s8a <- dloads %>%
  filter(
    dose != "control", 
    sample_type %in% c("liver", "kidney", "toeclip")
  ) %>%
  ggplot(aes(x = dose, y = log_vload, fill = dose)) +
  geom_boxplot() + 
  scale_x_discrete(limits = c("low", "high")) +
  scale_fill_manual(values = c(cTourq, cOrange)) +
  labs(title = "(a)", y = "Log viral load", x = "Dose") +
  facet_wrap(. ~ sample_type, labeller = tissue_labeller) + 
  geom_signif(comparisons = list(c("low", "high")), map_signif_level = TRUE, textsize = 3) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank()
         #        panel.border = element_blank()
  ) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        strip.text.x = element_text(size = 13),
        axis.title = element_text(size=13),
        axis.ticks.length = unit(.3, "cm")
  )

# (b) loads in all exposed animals swabbed at day 8 by dose
s8b <- dloads_pc8 %>%
  ggplot(aes(x = dose, y = log_vload, fill = dose)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("low", "high"), labels = c("Low", "High")) +
  scale_fill_manual(values = c(cTourq, cOrange)) +
  labs(title = "(b)", y = "Log viral load", x = "Dose") +
  geom_signif(comparisons = list(c("low", "high")), map_signif_level = TRUE, textsize = 4, annotations = c("**")) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        strip.text.x = element_text(size = 13),
        axis.title = element_text(size=13),
        axis.ticks.length = unit(.3, "cm")
  )

# alive vs dead
# (c) repeated measures on same individuals at day 8 and death using swabs
s8c <- dloads_repMeas %>% 
  ggplot(aes(x = sample_type, y = log_vload, fill = sample_type)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("pc8", "pc_pm"), labels = c("Day 8", "Death")) +
  scale_fill_manual(values = c(cTourq, cOrange)) +
  labs(title = "(c)", y = "Log viral load", x = "Sample time") +
  geom_signif(
    comparisons = list(c("pc8", "pc_pm")), 
    map_signif_level = TRUE, 
    textsize = 4
  ) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        strip.text.x = element_text(size = 13),
        axis.title = element_text(size=13),
        axis.ticks.length = unit(.3, "cm")
  )

# (d) tissue samples from midpoint euthanised versus dead
# all tissues combined
s8d <- dloads %>% 
  filter(dose == "low", sample_type == "liver" | sample_type == "kidney" | sample_type == "toeclip") %>%
  ggplot(aes(x = euth, y = log_vload, fill = euth)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("Y", "N"), labels = c("Euthanized", "Died")) +
  scale_fill_manual(values = c(cTourq, cOrange)) +
  labs(title = "(d)", y = "Log viral load", x = "Fate of individuals") +
  geom_signif(
    comparisons = list(c("Y", "N")), 
    map_signif_level = TRUE, 
    textsize = 4, 
    annotations = c("*")
  ) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        strip.text.x = element_text(size = 13),
        axis.title = element_text(size=13),
        axis.ticks.length = unit(.3, "cm")
  )
