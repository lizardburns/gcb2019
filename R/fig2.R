########################## fig 2 ===============================================

# compare trends ---------------------------------------------------------------
compare_trends <- tibble(time = rv_ts_gapFill$time,
                         ranavirus = c(rvtrend_ts_st),
                         temperature = c(temptrend_ts_st)) %>%
  gather(key = "Trend", value = "Measurement", -time) %>%
  ggplot(aes(x = time, y = Measurement, colour = Trend)) +
  geom_line(size = 1.2) +
  scale_colour_manual(values=c(cTourq, cOrange), labels = c("Ranvirosis occurence", "Temperature")) +
  scale_x_continuous(name = "Time",
                     breaks = c(0, 48, 108, 168, 228),
                     labels= c("1991", "1995", "2000", "2005", "2010")) +
  ylab("Scaled\nmeasurement") +
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
  )

# season -----------------------------------------------------------------------
smooth_season <- dvisreg_fit %>%
  filter(variable == "month") %>%
  transmute(month = x, rvfitted = rvfitted, lower = lower, upper = upper) %>%
  ggplot(aes(month, rvfitted)) +
  geom_line(colour = cTourq, size = 1.2) +
  geom_ribbon(aes(ymin = lower,
                  ymax = upper),
              alpha = 0.25,
              fill = cTourq) +
  geom_point(data = dvisreg_resid %>% filter(variable == "month"),
             aes(x, y), size = .4, alpha = .4) +
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
  scale_x_continuous(name = "Month",
                     breaks = c(1, 6, 11),
                     labels= c("Jan", "June", "Nov")) +
  ylab("")

# time -------------------------------------------------------------------------
time_trend <- dvisreg_fit %>%
  filter(variable == "time") %>%
  transmute(time = x, rvfitted = rvfitted, lower = lower, upper = upper) %>%
  ggplot(aes(time, rvfitted)) +
  geom_line(colour = cTourq, size = 1.2) +
  geom_ribbon(aes(ymin = lower,
                  ymax = upper),
              alpha = 0.25,
              fill = cTourq) +
  geom_point(data = dvisreg_resid %>% filter(variable == "time"),
             aes(x, y), size = .4, alpha = .4) +
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
  scale_x_continuous(name = "Time",
                     breaks = c(0, 108, 228),
                     labels= c("1991", "2000", "2010")) +
  ylab("")

# temp -------------------------------------------------------------------------
smooth_temp <- dvisreg_fit %>%
  filter(variable == "temptrend") %>%
  transmute(temp = x, rvfitted = rvfitted, lower = lower, upper = upper) %>%
  ggplot(aes(temp, rvfitted)) +
  geom_line(colour = cTourq, size = 1.2) +
  geom_ribbon(aes(ymin = lower,
                  ymax = upper),
              alpha = 0.25,
              fill = cTourq) +
  geom_point(data = dvisreg_resid %>% filter(variable == "temptrend"),
             aes(x, y), size = .4, alpha = .4) +
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
  scale_x_continuous(name = "Temperature /°C",
                     breaks = c(14.1, 14.4, 14.7, 15),
                     labels= c("14.1", "14.4", "14.7", "15.0")) +
  ylab("Change in ranavirosis rate")

# arrange panels ---------------------------------------------------------------
compare_trends <- arrangeGrob(compare_trends, top = a.title.grob)
smooth_temp <- arrangeGrob(smooth_temp, top = b.title.grob)
smooth_season <- arrangeGrob(smooth_season, top = c.title.grob)
time_trend <- arrangeGrob(time_trend, top = d.title.grob)

# pdf("fig2.pdf", width = 6.7, height = 6.7, paper = "a4", onefile = TRUE)
png("fig2.png")

grid.newpage()
pushViewport(viewport(x = unit(1, "mm"), 
                      y = unit(1, "npc") - unit(1, "mm"),
                      width = unit(1, "npc") - unit(2, "mm"),
                      height = unit(.45, "npc") - unit(1, "mm"),
                      just = c("left", "top"),
                      name = "vp2a"))
# grid.rect()
grid.draw(compare_trends)

upViewport()
pushViewport(viewport(x = unit(1, "mm"),
                      y = unit(1, "mm"),
                      width = unit(.36, "npc") - unit(1.5, "mm"),
                      height = unit(.55, "npc") - unit(2.5, "mm"),
                      just = c("left", "bottom"), 
                      name = "vp2bi"))
# grid.rect()
grid.draw(smooth_temp)

upViewport()
pushViewport(viewport(x = unit(1, "mm") + unit(.36, "npc"),
                      y = unit(1, "mm"),
                      width = unit(.32, "npc") - unit(1.5, "mm"),
                      height = unit(.55, "npc") - unit(2.5, "mm"),
                      just = c("left", "bottom"), 
                      name = "vp2bii"))
# grid.rect()
grid.draw(smooth_season)

upViewport()
pushViewport(viewport(x = unit(1, "mm") + unit(.68, "npc"),
                      y = unit(1, "mm"),
                      width = unit(.32, "npc") - unit(2, "mm"),
                      height = unit(.55, "npc") - unit(2.5, "mm"),
                      just = c("left", "bottom"), 
                      name = "vp2biii"))
# grid.rect()
grid.draw(time_trend)

dev.off()
