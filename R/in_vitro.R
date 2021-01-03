############################### in vitro =======================================

# summarise the TCID50 data
dfv3_invitro_summary <- d_fv3_invitro %>%
  group_by(temp, cell) %>%
  dplyr::summarise(n = n(),
                   lmean_tcid50ml = mean(ltcid),
                   sdev = sd(ltcid),
                   sem = sdev / sqrt(n))
# dfv3_invitro_summary

# linear model
m_invitro <- lm(
  ltcid ~ temp + cell,
  data = d_fv3_invitro
)
# summary(m_invitro)

m_invitro2 <- lm(
  ltcid ~ temp * cell,
  data = d_fv3_invitro
)
# summary(m_invitro2)
# anova(m_invitro, m_invitro2)

m_invitro3_iso <- lm(
  ltcid ~ temp * cell * isolate,
  data = d_fv3_invitro
)
# summary(m_invitro3_iso)
# dropterm(m_invitro3_iso, test = "F")
m_invitro_mam <- update(m_invitro3_iso, ~ . - temp:cell:isolate)
m_invitro_mam <- update(m_invitro_mam, ~ . - temp:cell)
m_invitro_mam <- update(m_invitro_mam, ~ . - cell:isolate)
m_invitro_mam <- update(m_invitro_mam, ~ . - temp:isolate)
# dropterm(m_invitro_mam, test = "F")
m_invitro_mam <- update(m_invitro_mam, ~ . - isolate)
# summary(m_invitro_mam)

# get model predictions and 95% confidence interval
grid_invitro <- d_fv3_invitro %>%
  data_grid(cell, temp = seq_range(temp, n = 21)) %>%
  mutate(
    pred = predict(m_invitro, newdata = ., type = "response", interval = "confidence")[,1],
    upr = predict(m_invitro, newdata = ., type = "response", interval = "confidence")[,3],
    lwr = predict(m_invitro, newdata = ., type = "response", interval = "confidence")[,2]
    )

