########################## fig1 ================================================

# fig 1a -----------------------------------------------------------------------
# prepare Fig 1a: relationship between ranavirus odds and temperature
# get the fitted lines and 95% confidence intervals
# formula for calculation of confidence interval: sCline(a, b)$linkinv(dfmp$maxt*d + c)
# Estimated confidence limits of functions of parameters using "Delta method" (from Bolker, http://ms.mcmaster.ca/~bolker/emdbook/chap7A.pdf, p.38)
critval <- qnorm(0.975)

grid_rv_maxt <- dfmp %>%
  data_grid(maxt = seq_range(maxt, n = 50)) %>%
  mutate(scline_pred = sCline(aFitted, bFitted)$linkinv(maxt*dFitted + cFitted))

dvar <- deltavar(
  fun = sCline(a, b)$linkinv(grid_rv_maxt$maxt*d + c), 
  meanval = coef(optRes), 
  Sigma = vcov(optRes)
)

sdapprox <- sqrt(dvar)
sClineUPR <- grid_rv_maxt$scline_pred + (critval * sdapprox)
sClineLWR <- grid_rv_maxt$scline_pred - (critval * sdapprox)

fig1a <- grid_rv_maxt %>%
  ggplot(aes(maxt)) +
  geom_point(data = d_binned_fmp, aes(x = xvals, y = yvals)) +
  geom_line(aes(y = scline_pred), data = grid_rv_maxt, colour = "red", size = 1) +
  # geom_line(aes(y = linear_pred), data = grid_rv_maxt, colour = "blue", size = 1) +
  geom_ribbon(aes(ymin = sClineLWR, ymax = sClineUPR), alpha=0.3) +
  # geom_ribbon(aes(ymin = linLWR, ymax = linUPR), alpha=0.3) +
  
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
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  xlab("Temperature /°C") +
  ylab("Proportion of\nranavirosis-consistent incidents")

fig1a <- arrangeGrob(fig1a, top = a.title.grob)

# Figs 1b and 1c ---------------------------------------------------------------
# Average temp and 16°C threshold against ranavirus status
dplos_csv <- dplos_csv %>%
  mutate(status = factor(ifelse(rv_event == 1, "Positive", "Negative")))

# boxplot - av. temp in preceding week
pPreciseBox <- dplos_csv %>% 
  ggplot(aes(x = status, y = av_temp_wk, fill = status)) +
  geom_boxplot(lwd = .8, width = .5, alpha = .65, outlier.alpha = 1) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(values=c(cTourq, cOrange)) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        axis.title = element_text(size=11),
        axis.ticks.length = unit(.3, "cm")
  ) +
  ylab("Av. temp. /°C") +
  xlab("Ranavirus status")

pPreciseBox <- arrangeGrob(pPreciseBox, top = b.title.grob)

# violin plot - number of consecutive days above 16°C in preceding week
pPreciseViol <- dplos_csv %>% 
  ggplot(aes(x = status, y = n16wk, fill = status)) +
  geom_violin(lwd = .8, alpha = .65) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(values=c(cTourq, cOrange)) +
  # legend:
  theme(legend.position="none") +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=11),
        axis.title = element_text(size=11),
        axis.ticks.length = unit(.3, "cm")
  ) +
  ylab("Days >16°C") +
  xlab("Ranavirus status")

pPreciseViol <- arrangeGrob(pPreciseViol, top = c.title.grob)

# Fig 1d: severity model visualisation
# plot fitted trends in severity against temp
fig1d <- ggplot(grid_rv_signs,
                aes(x = maxt,
                    y = fitt,
                    fill = factor(rv_signs_bin,
                                  labels = c("Negative", "Positive")),
                    colour = factor(rv_signs_bin,
                                    labels = c("Negative", "Positive")))
) +
  geom_line(size = 1.5) +
  geom_ribbon(aes(ymin = lwrt, ymax = uprt), alpha = .65) +
  # geom_point(data = dsev_fmp, aes(x = maxt, y = severity_hf), alpha = .4, shape = 20) +
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(values=c(cTourq, cOrange)) +
  scale_colour_manual(values=c(cTourq, cOrange)) +
  # legend:
  theme(legend.position = "right") +
  guides(fill = guide_legend(title = "Ranavirus\nstatus")) +
  guides(colour = FALSE) +
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  xlab("Temperature /°C") +
  # ylab("Estimated proportion of\nfrog population that died") +
  ylab("Severity") +
  labs(fill = "Ranavirus status", colour = "Ranavirus status")

fig1d <- arrangeGrob(fig1d, top = d.title.grob)

# Fig 1e: pond characteristics vs severity -------------------------------------
fig1e <- dsev_fmp %>% filter(!is.na(shading_pa)) %>% 
  ggplot(aes(
    x = factor(shading_pa,
               labels = c("None/Little", "Lots")),
    y = severity_hf,
    fill = factor(rv_signs_bin,
                  labels = c("Negative", "Positive")))) +
  
  # boxes:
  geom_boxplot(lwd=1, width=.5, alpha = .65) +
  
  # plot theme:
  theme_bw() +
  theme( panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.border = element_blank()
  ) +
  theme(text = element_text(size = 13)) +
  scale_fill_manual(name = "Ranavirus status",
                    values = c(cTourq, cOrange)) +
  # leave out the legend
  theme(legend.position="none") +
  
  # axes
  theme(axis.ticks = element_line(color='black', size = .7),
        axis.line = element_line(color='black', size = .7),
        axis.text = element_text(size=12),
        axis.title = element_text(size=15),
        axis.ticks.length = unit(.3, "cm")
  ) +
  
  ylab("Severity") +
  xlab("Shading")

fig1e <- arrangeGrob(fig1e, top = e.title.grob)

# arrange panels ---------------------------------------------------------------
# pdf("fig1.pdf", width = 6.7, height = 6.7, paper = "a4", onefile = TRUE)
png("fig1.png")
# dev.new(width = 6.7, height = 6.7)

grid.newpage()

pushViewport(viewport(x = unit(1, "mm"), 
                      y = unit(1, "npc") - unit(1, "mm"),
                      width = unit(.65, "npc"),
                      height = unit(.55, "npc"),
                      just = c("left", "top"),
                      name = "vp1a"))
# then insert the fig 1a plot
grid.draw(fig1a)
# grid.rect()

upViewport()

pushViewport(viewport(x = unit(2, "mm") + unit(.65, "npc"), 
                      y = unit(1, "npc") - unit(1, "mm"),
                      width = unit(.35, "npc") - unit(3, "mm"),
                      height = unit(.3, "npc") - unit(.5, "mm"),
                      just = c("left", "top"), 
                      name = "vp1b"))
# grid.rect()
grid.draw(pPreciseBox)

upViewport()

pushViewport(viewport(x = unit(2, "mm") + unit(.65, "npc"), 
                      y = unit(.7, "npc") - unit(1.5, "mm"),
                      width = unit(.35, "npc") - unit(3, "mm"),
                      height = unit(.25, "npc") - unit(.5, "mm"),
                      just = c("left", "top"),
                      name = "vp1c"))
# grid.rect()
grid.draw(pPreciseViol)

upViewport()

pushViewport(viewport(x = unit(1, "mm"), 
                      y = unit(1, "mm"),
                      width = unit(.55, "npc"),
                      height = unit(.45, "npc") - unit(3, "mm"),
                      just = c("left", "bottom"),
                      name = "vp1d"))
# grid.rect()
grid.draw(fig1d)

upViewport()

pushViewport(viewport(x = unit(.55, "npc") + unit(2, "mm"), 
                      y = unit(1, "mm"),
                      width = unit(.45, "npc") - unit(3, "mm"),
                      height = unit(.45, "npc") - unit(3, "mm"),
                      just = c("left", "bottom"),
                      name = "vp1e"))
# grid.rect()
grid.draw(fig1e)

dev.off()
