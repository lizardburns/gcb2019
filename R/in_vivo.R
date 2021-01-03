####################### in vivo - survival models ==============================

# cox with mixed-effects
msurv_me <- coxme(Surv(hpi, died) ~ virus + temp + (1 | box), dsurv)
# summary(msurv_me)

# get parameters from Cox proportional hazards for forest plot
coef.est <- c(NA, 
              0, 
              msurv_me$coefficients[2],
              msurv_me$coefficients[1], 
              NA, 
              0, 
              msurv_me$coefficients[3])

se.est <- c(NA, 
            0, 
            1.0476612, 
            1.1551823, 
            NA, 
            0, 
            0.5894594)

lower <- coef.est - 1.96*se.est
upper <- coef.est + 1.96*se.est

label.factors <- matrix(c("Exposure:", 
                          "    Sham", 
                          "    RUK11", 
                          "    RUK13", 
                          "Temperature:", 
                          "    Low (20°C)", 
                          "    High (27°C)"),
                        ncol=1)

# fit Kaplan-Meier survival model
dsurv$SurvObj <- with(dsurv, Surv(hpi, died))

km.treat <- survfit(SurvObj ~ virus + temp,
                    data = dsurv,
                    conf.type = "log-log")
# summary(km.treat)
