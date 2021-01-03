# Ranavirosis outbreaks in the wild - relationship with temperature

# epi-model1 -------------------------------------------------------------------
# full model with other pond characteristics
# simplify shading and vegetation variables (very subjective) so that they're 
# presence/absence

dfmp <- dfmp %>%
  mutate(
    shading_pa = case_when(
      is.na(Shading) ~ NA_real_, 
      Shading == "Very_shaded" ~ 1,
      TRUE ~ 0
    ) %>% 
      factor(),
    float_pa = case_when(
      is.na(Floating_veg) ~ NA_real_,
      Floating_veg == "Lots" ~ 1,
      TRUE ~ 0
    ) %>% 
      factor(),
    margin_pa = case_when(
      is.na(Marginal_veg) ~ NA_real_,
      Marginal_veg == "Lots" ~ 1,
      TRUE ~ 0
    ) %>% 
      factor(),
    log_pvol = log2(av_pvol),
    gor = factor(gor)
  )

m_incidence_temp_plus <- glm(
  rv ~ maxt * log_pvol + Toads + Newts + Fish + gor + shading_pa + float_pa + margin_pa,
  family = binomial(link = 'logit'), 
  data = dfmp
)

# summary(m_incidence_temp_plus)
# residualPlots(m_incidence_temp_plus)

# temperature retains a pattern in the residuals - needs quadratic term
m_incidence_temp_plus <- glm(
  rv ~ maxt * log_pvol + I(maxt^2) + 
    Toads + Newts + Fish + 
    gor + 
    shading_pa + float_pa + margin_pa, 
  family = binomial(link = 'logit'), 
  data = dfmp
)
# summary(m_incidence_temp_plus)
# residualPlots(m_incidence_temp_plus)
# anova(m_incidence_temp_plus, test="Chisq")

m_incidence_temp_plus1 <- update(
  m_incidence_temp_plus, 
  ~ . - maxt:log_pvol, 
  data=m_incidence_temp_plus$model
)
# summary(m_incidence_temp_plus1)
# anova(m_incidence_temp_plus1, test="Chisq")
# anova(m_incidence_temp_plus, m_incidence_temp_plus1, test="Chisq")

m_incidence_mam <- step(m_incidence_temp_plus1, direction = "both", test = "Chisq") 
# retained marginal vegetation
# summary(m_incidence_mam)
m_incidence_mam1 <- update(m_incidence_mam, ~ . - margin_pa)
# anova(m_incidence_mam, m_incidence_mam1, test="Chisq") 
# model doesn't suffer significantly for dropping marginal vegetation

# summary(m_incidence_mam1)
# residualPlots(m_incidence_mam1)
# marginalModelPlots(m_incidence_mam1)
# influenceIndexPlot(m_incidence_mam1, id.n = 3)
# influencePlot(m_incidence_mam1, col = 'red', id.n = 3)

# no impact of leaving out the big influence point (1981)
m_incidence_mam1981 <- update(m_incidence_mam1, subset = -c(1981))
# summary(m_incidence_mam1981)

# logistic with just temperature terms
# m_incidence_maxt <- glm(rv ~ maxt,
#                         family = binomial(link = 'logit'),
#                         data = dfmp)
# summary(m_incidence_maxt)
# anova(m_incidence_maxt, test="Chisq")

m_incidence_maxt2 <- glm(
  rv ~ maxt + I(maxt^2),
  family = binomial(link = 'logit'),
  data = dfmp
)
# summary(m_incidence_maxt2)
# anova(m_incidence_maxt2, test="Chisq")

# epi-model2 -------------------------------------------------------------------
# place the data in temperature bins to calculate proportion of incidents caused by ranavirus
# number of bins for smoothing
nbins <- 30

# find rank order of the temperature values
tempOrder <- order(dfmp$maxt)

# calculate the mean number of observations per bin
binSize <- length(dfmp$maxt)/nbins

# find internal boundaries 
iBounds <- round(1:(nbins-1)*binSize)

binMin <- c(1, iBounds)
binMax <- c(iBounds, length(dfmp$maxt))

# set up variates for smoothed values
xvals <- rep(NA, (nbins-1))
yvals <- xvals
nsuccess <- xvals
nfail <- xvals

for (i in 1:(nbins-1)){
  invals <- binMin[i]:binMax[i]
  xvals[i] <- mean(dfmp$maxt[tempOrder][invals])
  yvals[i] <- mean(dfmp$rv[tempOrder][invals])
  nsuccess[i] <- sum(dfmp$rv[tempOrder][invals])
  nfail[i] <- length(dfmp$rv[tempOrder][invals]) - sum(dfmp$rv[tempOrder][invals])
}

d_binned_fmp <- data.frame(xvals, yvals, nsuccess, nfail)

m_incid_sCline <- glm2(rv ~ maxt,
                       family = binomial(link = sCline(0.25, 0.38)),
                       data = dfmp,
                       start = c(-14.5, 1)
)
# summary(m_incid_sCline)
# anova(m_incid_sCline, test = "Chi")

# use sCline with a max likelihood estimator to estimate upper and lower bounds
optAll <- function(a = 0.25,
                   b = .39,
                   c = m_incid_sCline$coefficients[1],
                   d = m_incid_sCline$coefficients[2])
{
  -sum(dbinom(x = dfmp$rv,
              size = 1,
              prob = sCline(a, b)$linkinv(c + d*dfmp$maxt),
              log = TRUE)
  )
}

# optimize a value starting from mlvalues
mle2(minuslogl = optAll,
     start = list(a = 0.25),
     fixed = list(b = 0.38,
                  c = m_incid_sCline$coefficients[1],
                  d = m_incid_sCline$coefficients[2])
)

# optimize all four values together
optRes <- mle2(optAll,
               start = list(a = 0.25, b = 0.38, c = m_incid_sCline$coefficients[1],
                            d = m_incid_sCline$coefficients[2])
) 	

aFitted <- optRes@coef['a']
bFitted <- optRes@coef['b']
cFitted <- optRes@coef['c']
dFitted <- optRes@coef['d']

fineFit <- sCline(aFitted, bFitted)

# summary(optRes)
m_incidsCline_opt <- glm2(rv ~ maxt,
                          family = binomial(link = sCline(aFitted, bFitted)),
                          data = dfmp,
                          start = c(cFitted, dFitted)
)

# AIC(m_incidence_maxt2, optRes)

# severity - simple GLM --------------------------------------------------------
# Is there an interaction between temperature and ranavirus status that 
# describes increased severity for ranavirus incidents when it's hot?
# make a data table
dsev_fmp <- dfmp %>% 
  filter(!is.na(totdead), !is.na(Healthyfrogs), !is.na(rv_signs))

# remove records with likely errors in the total number of dead frogs or the 
# healthy frog population size
dsev_fmp <- dplyr::slice(
  dsev_fmp, 
  setdiff(1:nrow(dsev_fmp), c(322, 496, 650, 251))
  ) 
# masterid 333, 524, 700 and 255

### Severity after filtering by rv signs: model output and predictions
m_sev_rvsigns_temp <- glm(
  cbind(totdead, Healthyfrogs) ~ rv_signs_bin * maxt,
  family = quasibinomial,
  data = dsev_fmp
)
# summary(m_sev_rvsigns_temp)
# anova(m_sev_rvsigns_temp, test="F")

# get the fitted lines and 95% confidence intervals
critval <- qnorm(0.975)
grid_rv_signs <- dsev_fmp %>% 
  data_grid(maxt = seq_range(maxt, n = 10),
            rv_signs_bin = rv_signs_bin) %>%
  mutate(
    fitted = predict(m_sev_rvsigns_temp, newdata = ., type = "link", se.fit = TRUE)$fit,
    se_fitted = predict(m_sev_rvsigns_temp, newdata = ., type = "link", se.fit = TRUE)$se.fit,
    upr = fitted + (critval * se_fitted),
    lwr = fitted - (critval * se_fitted),
    fitt = m_sev_rvsigns_temp$family$linkinv(fitted),
    uprt = m_sev_rvsigns_temp$family$linkinv(upr),
    lwrt = m_sev_rvsigns_temp$family$linkinv(lwr)
  )

# severity - extended GLM with other pond variables ----------------------------
m_sev_rvtemp_full <- glm(
  cbind(totdead, Healthyfrogs) ~ 
    rv_signs_bin * maxt + log_pvol + shading_pa + margin_pa + float_pa + 
    Toads + Newts + Fish + 
    gor,
  family = quasibinomial,
  data = dsev_fmp
)

# summary(m_sev_rvtemp_full)
# residualPlots(m_sev_rvtemp_full)

m_sev_rvtemp_full <- glm(
  cbind(totdead, Healthyfrogs) ~ 
    rv_signs_bin * maxt + log_pvol + I(log_pvol^2) + 
    shading_pa + margin_pa + float_pa + 
    Toads + Newts + Fish + 
    gor,
  family = quasibinomial,
  data = dsev_fmp
)
# summary(m_sev_rvtemp_full)
# residualPlots(m_sev_rvtemp_full)

m_sev_rvtemp_full <- glm(
  cbind(totdead, Healthyfrogs) ~ 
    rv_signs_bin * maxt + log_pvol + I(log_pvol^2) + I(log_pvol^4) + 
    shading_pa + margin_pa + float_pa + 
    Toads + Newts + Fish + 
    gor,
  family = quasibinomial,
  data = dsev_fmp
)
# summary(m_sev_rvtemp_full)
# residualPlots(m_sev_rvtemp_full)

# anova(m_sev_rvtemp_full, test="F")

# model simplification
dropterm(m_sev_rvtemp_full, test = "F")
m_sev_rvtemp_full_mam <- update(m_sev_rvtemp_full, ~ . - Newts)
# m_sev_rvtemp_full_mam <- update(m_sev_rvtemp_full_mam, ~ . - shading_pa)
m_sev_rvtemp_full_mam <- update(m_sev_rvtemp_full_mam, ~ . - float_pa)
# m_sev_rvtemp_full_mam <- update(m_sev_rvtemp_full_mam, ~ . - margin_pa)
m_sev_rvtemp_full_mam <- update(m_sev_rvtemp_full_mam, ~ . - I(log_pvol^4))
dropterm(m_sev_rvtemp_full_mam, test = "F")
# summary(m_sev_rvtemp_full_mam)
# residualPlots(m_sev_rvtemp_full_mam)
# anova(m_sev_rvtemp_full_mam, test="F")

# summary(update(m_sev_rvtemp_full_mam, ~ . + rv_signs_bin:log_pvol)) 
# no interaction of pond volume, Fish, Toads, shading or marginal vegetation 
# with cause of incident (rv vs. other) when added to model afterwards like this
# Does this suggest that this is more about carcase detection in different sized 
# ponds

# ggplot(dsev_fmp, aes(x = log_pvol, y = severity_hf, colour = rv_signs_bin)) +
#   geom_point()

# pond volume
# dsev_fmp %>% 
#   data_grid(log_pvol = seq_range(log_pvol, n = 10),
#             rv_signs_bin = rv_signs_bin) %>%
#   mutate(
#     fitted = predict(glm(cbind(totdead, Healthyfrogs) ~ rv_signs_bin * log_pvol, family = quasibinomial, data = dsev_fmp), newdata = ., type = "link", se.fit = TRUE)$fit,
#     se_fitted = predict(glm(cbind(totdead, Healthyfrogs) ~ rv_signs_bin * log_pvol, family = quasibinomial, data = dsev_fmp), newdata = ., type = "link", se.fit = TRUE)$se.fit,
#     upr = fitted + (critval * se_fitted),
#     lwr = fitted - (critval * se_fitted),
#     fitt = glm(cbind(totdead, Healthyfrogs) ~ rv_signs_bin * log_pvol, family = quasibinomial, data = dsev_fmp)$family$linkinv(fitted),
#     uprt = glm(cbind(totdead, Healthyfrogs) ~ rv_signs_bin * log_pvol, family = quasibinomial, data = dsev_fmp)$family$linkinv(upr),
#     lwrt = glm(cbind(totdead, Healthyfrogs) ~ rv_signs_bin * log_pvol, family = quasibinomial, data = dsev_fmp)$family$linkinv(lwr)
#   ) %>%
#   ggplot(aes(x = log_pvol,
#              y = fitt,
#              fill = factor(rv_signs_bin,
#                            labels = c("Negative", "Positive")),
#              colour = factor(rv_signs_bin,
#                              labels = c("Negative", "Positive")))
#   ) +
#   geom_line(size = 1.5) +
#   geom_ribbon(aes(ymin = lwrt, ymax = uprt), alpha = .65)
