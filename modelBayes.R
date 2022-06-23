
#library(rstanarm)
options(mc.cores = 1)
library(projpred)
library(haven) #for reading sav data
library(sjstats) #for calculating intra-class correlation (ICC)
 #for Bayesian (multilevel) generalised linear modelling
library(modelr)


# Modelo 1

model <- brm(formula = cancer_c ~ age_c + assess_c + famhx_c + density_c +bmi_c,
             data=df.f, 
             family = bernoulli(link = "logit"),
             warmup = 3000, 
             iter = 15000, 
             chains = 3, 
             inits= "0", 
             cores=2,
             seed = 123)

summary(model)

bayesplot::color_scheme_set("brightblue")

pplot <- plot(model,plotfun='areas',prob = 0.95, prob_outer = 1)

name <- paste0("b_",model2[["prior"]][["coef"]])[c(-1,-14)]
i =1

mcmc_areas(
  model2, 
  pars = name[i],
  prob = 0.95, # 80% intervals
  prob_outer = 0.99, # 99%
  point_est = "mean"
)



mcmc_nuts_energy(np2)
# Modelo 2 




# Diagnostico visual del MCMC

## Rhat

rhats <- rhat(model)
print(rhats)

color_scheme_set("brightblue")
mcmc_rhat(rhats)+ yaxis_text(hjust = 1)



## N_eff

ratios <- neff_ratio(model)
print(ratios)

mcmc_neff(ratios, size = 2) + yaxis_text(hjust = 1)



  #-------------------------------
compare_cp_ncp <- function(cp_plot, ncp_plot, ncol = 2, ...) {
  bayesplot_grid(
    cp_plot, ncp_plot, 
    grid_args = list(ncol = ncol),
    subtitles = c("Model 1", 
                  "Model 2"),
    ...
  )
}
#------------------------------



# Si son estacionarios!!!!!

## Autocorrelación
p <- model[["prior"]][["coef"]]
p <- p[c(-1,-10)]
i  = 1
compare_cp_ncp(
  mcmc_acf(model, pars = paste0("b_",p[i]), lags = 10),
  mcmc_acf(model2, pars = paste0("b_",p[i]), lags = 10)
)


#  par coord
np <- nuts_params(model)
np2 <- nuts_params(model2)

color_scheme_set("darkgray")
mcmc_parcoord(model2, np = np2)

# Nuts posterior:

lp <- log_posterior(model)



