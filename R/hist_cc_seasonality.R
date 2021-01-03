################# Historic climate change and seasonality ======================

# decompose seasonality and trend over years with gam --------------------------
# summarise the temp data across geographies where mortality incidents occurred 
# by month for all years
avtemp <- dfmp %>%
  dplyr::select(mort_start_y1, mort_start_m1, maxt) %>%
  mutate(month = as.integer(mort_start_m1)) %>%
  group_by(mort_start_y1, month) %>%
  dplyr::summarise(temp = mean(maxt)) %>%
  ungroup() %>% 
  mutate(day = 1, date = dmy(paste(day, month, mort_start_y1)))

# fill the gaps
all_dates <- seq(dmy(1011991), dmy(1122010), by="month")
all_dates <- data.frame(list(date=all_dates))
avtemp_gapFill <- merge(all_dates, avtemp, all = T) %>%
  mutate(time = 1:240) %>%
  as_tibble()

# summarise the ranavirus data nationally by month for all years ---------------
rv_time <- dfmp %>%
  dplyr::select(mort_start_y1, mort_start_m1, rv) %>%
  mutate(month = as.integer(mort_start_m1),
         ranavirus = if_else(rv == 0, "neg", if_else(rv == 1, "pos", "NA"))) %>%
  dplyr::count(mort_start_y1, month, ranavirus, name = "count") %>%
  spread(ranavirus, count) %>%
  mutate(prop = pos/(neg+pos),
         day = 1,
         date = dmy(paste(day,month,mort_start_y1)),
         prop_nona = if_else(is.na(prop), 0, prop))

rv_ts_gapFill <- merge(all_dates, rv_time, all = TRUE) %>%
  mutate(time = 1:240) %>%
  as_tibble()

# temperature decomposition ----------------------------------------------------
m_temp_decomp <- gamm(temp ~ s(month, bs = "cc") + s(time, bs = "cr"),
                      data = avtemp_gapFill,
                      method = "REML",
                      correlation = corAR1(form = ~ 1 | mort_start_y1))

# summary(m_temp_decomp$gam)
# plot(m_temp_decomp$gam, scale = 0, pages = 1)

# fitted values (predictions from model)
temp_pred_eachTerm <- predict(
  m_temp_decomp$gam, 
  newdata = avtemp_gapFill, 
  type = "terms"
  )
ptemp_time_vals <- attr(temp_pred_eachTerm, "constant") + temp_pred_eachTerm[,2]
temp_pred_model <- predict(m_temp_decomp$gam, newdata = avtemp_gapFill)

# ranavirus --------------------------------------------------------------------
m_rv_decomp <- gamm(prop_nona ~ s(month, bs = "cc") + s(time, bs = "cr"),
                    data = rv_ts_gapFill,
                    method = "REML",
                    correlation = corAR1(form = ~ 1 | mort_start_y1))

# summary(m_rv_decomp$gam)
# plot(m_rv_decomp$gam, scale = 0, pages = 1)

rv_pred_eachTerm <- predict(m_rv_decomp$gam, newdata = rv_ts_gapFill, type = "terms")
prv_time_vals <- attr(rv_pred_eachTerm, "constant") + rv_pred_eachTerm[,2]
rv_pred_model <- predict(m_rv_decomp$gam, newdata = rv_ts_gapFill)

# sort out missing data & transform predictions to standardised (0-1) scale ----
rvtrend_ts <- ts(prv_time_vals, frequency = 12)
rvtrend_ts[1] <- 0.132
rvtrend_ts <- na.StructTS(rvtrend_ts)

temptrend_ts <- ts(ptemp_time_vals, frequency = 12)
temptrend_ts[1] <- 14.1
temptrend_ts <- na.StructTS(temptrend_ts)

rvtrend_ts_st <- (rvtrend_ts-min(rvtrend_ts, na.rm = TRUE)) / 
  (max(rvtrend_ts-min(rvtrend_ts, na.rm = TRUE), na.rm = TRUE))
temptrend_ts_st <- (temptrend_ts-min(temptrend_ts, na.rm = TRUE)) / 
  (max(temptrend_ts-min(temptrend_ts, na.rm = TRUE), na.rm = TRUE))

# historic climate - binomial model of rv rate ---------------------------------
# compile data - all the NAs in neg and pos can be 0s
d_gam_bin <- rv_ts_gapFill %>%
  dplyr::select(date, time, neg, pos) %>%
  mutate(month = month(date),
         temptrend = c(temptrend_ts)) %>%
  dplyr::select(date, month, time, temptrend, neg, pos)
# replace the NAs in neg where there are positive reports
d_gam_bin$neg[!is.na(d_gam_bin$pos)][is.na(d_gam_bin$neg[!is.na(d_gam_bin$pos)])] <- 0
# replace the NAs in pos where there are negative reports
d_gam_bin$pos[is.na(d_gam_bin$pos)][!is.na(d_gam_bin$neg[is.na(d_gam_bin$pos)])] <- 0

rv_gam_bin <- cbind(as.integer(d_gam_bin$pos), as.integer(d_gam_bin$neg))

# with smoothed time trend
# m_gam_bin_wTime <- gam(rv_gam_bin ~ s(month, bs = "cc") + s(time, bs = "cr") + s(temptrend, bs = "cr"), data = d_gam_bin, family = binomial())
# # use concurvity to compare the two time trends?
# concurvity(m_gam_bin_wTime, full=FALSE)

# binomial model with parrametric time trend -----------------------------------
m_gam_bin_wTime <- gam(
  rv_gam_bin ~ 
    s(month, bs = "cc") + time + s(temptrend, bs = "cr"), 
  data = d_gam_bin, 
  family = binomial()
  )
# summary(m_gam_bin_wTime)

# model checks
# gam.check(m_gam_bin_wTime)
# acf(residuals(m_gam_bin_wTime), lag.max = 240)
# concurvity(m_gam_bin_wTime, full=FALSE)

# Visualise gam
# pull data out of gam
tmp <- visreg(
  gam(
    cbind(as.integer(pos), as.integer(neg)) ~ 
      s(month, bs = "cc") + time + s(temptrend, bs = "cr"), 
    data = d_gam_bin, 
    family = binomial()
    ),
  plot = FALSE, 
  cond = list(time = 1)
  )

pred_gaps <- as.vector(predict(m_gam_bin_wTime, type = "response"))
pred <- rep(NA, 240)
pred[as.integer(attr(predict(m_gam_bin_wTime, type = "response"), which = "dimnames")[[1]])] <- pred_gaps

dvisreg_fit <- as_tibble(
  ldply(tmp,
        function(part) tibble(variable = part$meta$x,
                              x = part$fit[[variable]],
                              rvfitted = part$fit$visregFit,
                              lower = part$fit$visregLwr,
                              upper = part$fit$visregUpr))
  )
dvisreg_resid <- as_tibble(
  ldply(tmp,
        function(part) tibble(variable = part$meta$x,
                              x=part$res[[variable]],
                              y=part$res$visregRes))
  )

# plot model 
plot_gambin <- tibble(time = rv_ts_gapFill$time,
                      obs = rv_ts_gapFill$prop_nona,
                      pred = pred) %>%
  ggplot(aes(x = time)) +
  geom_point(aes(y = obs), size = .7, alpha = .5) +
  geom_line(aes(y = pred), colour = cTourq) +
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
                     breaks = c(0, 48, 108, 168, 228),
                     labels= c("1991", "1995", "2000", "2005", "2010")) +
  ylab("Ranavirosis incidence rate")

# forecasting power - time vs temp ---------------------------------------------
# using training subsets (50% & 75%) then predicting from models with time or temp
# train on first 10 yrs
# nrow(d_gam_bin[1:120,][!is.na(d_gam_bin$pos[1:120]),]) # 102
# nrow(d_gam_bin[121:240,][!is.na(d_gam_bin$pos[121:240]),]) # 108
d_gam_bin_train50 <- d_gam_bin[1:120,]
d_gam_bin_test50 <- d_gam_bin[121:240,]
rv_gam_train50 <- cbind(
  as.integer(d_gam_bin_train50$pos), 
  as.integer(d_gam_bin_train50$neg)
  )

m_gb50_time <- gam(
  rv_gam_train50 ~ s(month, bs = "cc") + s(time, bs = "cr"), 
  data = d_gam_bin_train50, 
  family = binomial()
  )
m_gb50_temp <- gam(
  rv_gam_train50 ~ s(month, bs = "cc") + s(temptrend, bs = "cr"), 
  data = d_gam_bin_train50, 
  family = binomial()
  )
# summary(m_gb50_time)
# summary(m_gb50_temp)
# almost identical in amount of deviance explained
pred_mgb50_time <- predict(m_gb50_time, d_gam_bin_test50)

# train on first 15 yrs
# nrow(d_gam_bin[1:180,][!is.na(d_gam_bin$pos[1:180]),]) # 159
# nrow(d_gam_bin[181:240,][!is.na(d_gam_bin$pos[181:240]),]) # 51
d_gam_bin_train75 <- d_gam_bin[1:180,]
d_gam_bin_test75 <- d_gam_bin[181:240,]
rv_gam_train75 <- cbind(
  as.integer(d_gam_bin_train75$pos), 
  as.integer(d_gam_bin_train75$neg)
  )

m_gb75_time <- gam(
  rv_gam_train75 ~ s(month, bs = "cc") + s(time, bs = "cr"), 
  data = d_gam_bin_train75, 
  family = binomial()
  )
m_gb75_temp <- gam(
  rv_gam_train75 ~ s(month, bs = "cc") + s(temptrend, bs = "cr"), 
  data = d_gam_bin_train75, 
  family = binomial()
  )
# summary(m_gb75_time)
# summary(m_gb75_temp)

# temp explains more of the deviance now
