# PM db - model outbreaks with climatic variables

nday_before <- 50
# logistic regression on average temp in the week before ----
# without variables to explicitly control for geography
m_precise_avtemp7 <- glm(rv_event ~ av_temp_wk,
                         family = binomial(link = 'logit'),
                         data = dplos_csv
)
# summary(m_precise_avtemp7)

# no impact of including variables to explicitly control for geography (region/latitude)
m_precise_avtemp_gor <- glm(rv_event ~ gor + av_temp_wk,
                            family = binomial(link = 'logit'),
                            data = dplos_csv
)
# summary(m_precise_avtemp_gor)

m_precise_avtemp_lat <- glm(rv_event ~ y + av_temp_wk,
                            family = binomial(link = 'logit'),
                            data = dplos_csv
)
# summary(m_precise_avtemp_lat)

# logistic regression on number of consecutive days above 16°C in the previous 50 ----
m_precise_n16 <- glm(rv_event ~ n16,
                     family = binomial(link = 'logit'),
                     data = dplos_csv
)
# summary(m_precise_n16)
# plot(m_precise_n16)

# no impact of controlling for region 
m_precise_n16_gor <- glm(rv_event ~ n16 + gor,
                         family = binomial(link = 'logit'),
                         data = dplos_csv)
# summary(m_precise_n16_gor)

m_precise_n16_lat <- glm(rv_event ~ y + n16,
                         family = binomial(link = 'logit'),
                         data = dplos_csv)
# summary(m_precise_n16_lat)

# dplos_csv %>%
#   ggplot(aes(x = factor(rv_event),
#              y = n16,
#              colour = factor(rv_event))
#          ) +
#   geom_violin()

# logistic regression on number of consecutive days above 16°C in preceding week ----
m_precise_n16wk <- glm(rv_event ~ n16wk,
                       family = binomial(link = 'logit'),
                       data = dplos_csv)
# summary(m_precise_n16wk)
