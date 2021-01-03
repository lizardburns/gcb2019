# Fig S1 analysis and base-plotting - what is disease --------------------------
# treatment sample sizes
# dsigns %>%
#   dplyr::select(dose) %>%
#   dplyr::count(dose)
# control 22, low 26, high 22

# signs of interest
sign_names <- list(
  "limbs_red" = str_wrap("Haemorrhaging in limbs", width = 14),
  "lips_red" = str_wrap("Haemorrhaging in lips", width = 14),
  "petechiae" = str_wrap("Petechial haemorrhaging", width = 14),
  "ulcer_pm" = str_wrap("Ulceration", width = 14)
)

# summarise data
# generate proportions (animals with signs by exposure gp (exposed - yes/no))
dsigns_prop_byExposure <- dsigns %>%
  gather(limbs_red:skin_slough, key = "sign", value = "presence_absence") %>%
  dplyr::select(exposed, sign, presence_absence) %>%
  filter(presence_absence == "yes") %>%
  dplyr::count(exposed, sign, name = "count") %>%
  mutate(N = if_else(exposed == "no", 22, 48),
         proportion = count / N)

# stats
# limbs_red
limbs_red <- dsigns_prop_byExposure %>%
  filter(sign == "limbs_red") %>%
  dplyr::select(count, N)

# prop.test(limbs_red$count, limbs_red$N)
# fisher.test(limbs_red)

# lips_red
lips_red <- dsigns_prop_byExposure %>%
  filter(sign == "lips_red") %>%
  dplyr::select(count, N)

lips_red <- rbind(c(0,22), lips_red)

# prop.test(lips_red$count, lips_red$N)
# fisher.test(lips_red)

# petechiae
petechiae <- dsigns_prop_byExposure %>%
  filter(sign == "petechiae") %>%
  dplyr::select(count, N)

# prop.test(petechiae$count, petechiae$N)
# fisher.test(petechiae)

# ulcer_pm
ulcer_pm <- dsigns_prop_byExposure %>%
  filter(sign == "ulcer_pm") %>%
  dplyr::select(count, N)

# prop.test(ulcer_pm$count, ulcer_pm$N)
# fisher.test(ulcer_pm)

# plot base fig S1
dsigns_prop_byExposure %>%
  filter(sign == "limbs_red" | sign == "lips_red" | sign == "petechiae" | sign == "ulcer_pm") %>%
  ggplot(aes(x = exposed, y = proportion, fill = exposed)) +
  geom_col() +
  scale_x_discrete(limits = c("no", "yes")) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c(cTourq, cOrange)) +
  labs(x = "Exposed", y = "Occurence of signs of\nranavirosis (%age of frogs)") +
  facet_grid(. ~ sign, labeller = sign_labeller) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank()
         #        panel.border = element_blank()
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

# Fig S3: compare temp distribution by ranavirus status ---------------------
p_maxt_bp <- dfmp %>% 
  ggplot(aes(y = maxt, x = ranavirus, fill = ranavirus)) + 
  # boxes:
  geom_boxplot(lwd=1, width=.5) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(labels=c("Negative", "Positive"),
                    values = c("#888888", "#FFFFFF")) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  xlab("Ranavirus status") +
  ylab("Temperature /°C") +
  scale_x_discrete(labels=c("Negative", "Positive"))

p_maxt_bp <- arrangeGrob(p_maxt_bp, top = a.title.grob)

p_maxt_violin <- dfmp %>% 
  ggplot(aes(y = maxt, x = ranavirus, fill = ranavirus)) + 
  geom_violin(lwd=.8) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(labels=c("Negative", "Positive"),
                    values = c("#888888", "#FFFFFF")) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  xlab("Ranavirus status") +
  ylab("Temperature /°C") +
  scale_x_discrete(labels=c("Negative", "Positive"))

p_maxt_violin <- arrangeGrob(p_maxt_violin, top = b.title.grob)

# Fig S5 - effects of other species from severity model ------------------------
# TOADS
pSevToads <- dsev_fmp %>% 
  ggplot(aes(
    x = factor(Toads, labels = c("Absent", "Present")), 
    y = severity_hf, 
    fill = factor(rv_signs_bin, labels = c("Negative", "Positive"))
    )
    ) +
  # boxes:
  # stat_boxplot(geom ='errorbar', width=0.1, lwd=1) +
  geom_boxplot(lwd=1, width=.5) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(name = "Ranavirus status",
                    values = c("#888888", "#FFFFFF")) +
  # legend:
  guides(fill = guide_legend(override.aes = list(lwd = c(.6, .6)))) +
  theme(legend.position="right",
        legend.text = element_text(colour = "black", size = 13, face = "plain"),
        legend.key.size = unit(1, "cm")
  ) +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  ylab("Severity") + 
  xlab("Toads")

pSevToads <- arrangeGrob(pSevToads, top = a.title.grob)

# FISH
pSevFish <- dsev_fmp %>% 
  ggplot(aes(
    x = factor(Fish, labels = c("Absent", "Present")), 
    y = severity_hf, 
    fill = factor(rv_signs_bin, labels = c("Negative", "Positive"))
    )
    ) +
  # boxes:
  geom_boxplot(lwd=1, width=.5) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(name = "Ranavirus status",
                    values = c("#888888", "#FFFFFF")) +
  # legend:
  guides(fill = guide_legend(override.aes = list(lwd = c(.6, .6)))) +
  theme(legend.position = "right",
        legend.text = element_text(colour = "black", size = 13, face = "plain"),
        legend.key.size = unit(1, "cm")
  ) +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  ylab("Severity") +
  xlab("Fish")

pSevFish <- arrangeGrob(pSevFish, top = b.title.grob)

# Fig S6 - forecasting power ---------------------------------------------------
figS6a <- ggplot() +
  # data
  geom_point(data = d_gam_bin_train50[!is.na(d_gam_bin_train50$pos),], 
             aes(x = time, y = pos/(pos + neg), colour = "Training"), alpha = .4) +
  geom_point(data = d_gam_bin_test50[!is.na(d_gam_bin_test50$pos),], 
             aes(x = time, y = pos/(pos + neg), colour = "Test"),
             alpha = .4) +
  # fit to training data
  geom_smooth(data = d_gam_bin_train50[!is.na(d_gam_bin_train50$pos),], 
              aes(x = time, y=predict(m_gb50_time, type="response"), 
                  fill = "Time"), 
              colour= cOrange, alpha = .2) +
  geom_smooth(data = d_gam_bin_train50[!is.na(d_gam_bin_train50$pos),], 
              aes(x = time, y=predict(m_gb50_temp, type="response"),
                  fill = "Temperature"), 
              colour = cTourq, alpha = .2) +
  # predictions against test
  geom_smooth(data = d_gam_bin_test50[!is.na(d_gam_bin_test50$pos),], 
              aes(x = time, 
                  y=predict(m_gb50_time,
                            newdata = d_gam_bin_test50[!is.na(d_gam_bin_test50$pos),],
                            type="response")), 
              colour = cOrange, fill = cOrange, alpha = .2) +
  geom_smooth(data = d_gam_bin_test50[!is.na(d_gam_bin_test50$pos),], 
              aes(x = time, 
                  y=predict(m_gb50_temp,
                            newdata = d_gam_bin_test50[!is.na(d_gam_bin_test50$pos),],
                            type="response")), 
              colour = cTourq, fill = cTourq, alpha = .2) +
  geom_vline(xintercept = 120, size = 2, linetype = "solid", alpha = .3) +
  # theme and style
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()) +
  theme(text = element_text(size = 13)) +
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  scale_x_continuous(name = "Time", breaks = c(0, 48, 108, 168, 228),
                     labels= c("1991", "1995", "2000", "2005", "2010")) +
  ylab("Proportion of\nranavirosis-consistent incidents") +
  scale_colour_manual(name = "Dataset:", limits = c("Training", "Test"),
                      values = c(Training = "black", Test = cViolet)) +
  scale_fill_manual(name = "Model:", values = c(Time = cOrange, Temperature = cTourq)) +
  guides(fill = guide_legend(override.aes = list(size=0)),
         colour = guide_legend(override.aes = list(size=3)))

figS6a <- arrangeGrob(figS6a, top = a.title.grob)

figS6b <- ggplot() +
  geom_point(data = d_gam_bin_train75[!is.na(d_gam_bin_train75$pos),], 
             aes(x = time, y = pos/(pos + neg), colour = "Training"), alpha = .4) +
  geom_point(data = d_gam_bin_test75[!is.na(d_gam_bin_test75$pos),], 
             aes(x = time, y = pos/(pos + neg), colour = "Test"),
             colour = cViolet, alpha = .4) +
  geom_smooth(data = d_gam_bin_train75[!is.na(d_gam_bin_train75$pos),], 
              aes(x = time, y=predict(m_gb75_time, type="response"), fill = "Time"), 
              colour = cOrange, alpha = .2, span = .6) +
  geom_smooth(data = d_gam_bin_train75[!is.na(d_gam_bin_train75$pos),], 
              aes(x = time, y=predict(m_gb75_temp, type="response"), fill = "Temperature"), 
              colour = cTourq, alpha = .2, span = .6) +
  geom_smooth(data = d_gam_bin_test75[!is.na(d_gam_bin_test75$pos),], 
              aes(x = time, 
                  y=predict(m_gb75_time,
                            newdata = d_gam_bin_test75[!is.na(d_gam_bin_test75$pos),],
                            type="response")), 
              colour = cOrange, fill = cOrange, alpha = .2, span = 1.2) +
  geom_smooth(data = d_gam_bin_test75[!is.na(d_gam_bin_test75$pos),], 
              aes(x = time, 
                  y=predict(m_gb75_temp,
                            newdata = d_gam_bin_test75[!is.na(d_gam_bin_test75$pos),],
                            type="response")), 
              colour = cTourq, fill = cTourq, alpha = .2, span = 1.2) +
  geom_vline(xintercept = 181, size = 2, linetype = "solid", alpha = .3) +
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()) +
  theme(text = element_text(size = 13)) +
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  scale_x_continuous(name = "Time", breaks = c(0, 48, 108, 168, 228),
                     labels= c("1991", "1995", "2000", "2005", "2010")) +
  ylab("Proportion of\nranavirosis-consistent incidents") +
  scale_colour_manual(name = "Dataset:", limits = c("Training", "Test"),
                      values = c(Training = "black", Test = cViolet)) +
  scale_fill_manual(name = "Model:", values = c(Time = cOrange, Temperature = cTourq)) +
  guides(fill = guide_legend(override.aes = list(size=0)),
         colour = guide_legend(override.aes = list(size=3)))

figS6b <- arrangeGrob(figS6b, top = b.title.grob)
