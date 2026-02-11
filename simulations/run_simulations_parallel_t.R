####################################################################
# BIOS 731: Advanced Statistical Computing
#
####################################################################


library(tidyverse)
library(broom) # for 03_extract_estimates

###############################################################
## define or source functions used in code below
###############################################################

source(here::here("source", "01_simulate_data.R"))
source(here::here("source", "02_apply_methods.R"))
#source(here::here("source", "03_extract_estimates.R"))
source(here::here("source", "aggregate_results.R"))

###############################################################
## set simulation design elements
###############################################################

# how are you justifying nsim?
coverage = 0.95
MC_error = 0.01
nsim = (1-coverage)*coverage/(MC_error^2)

n = c(10, 50, 100)
beta_true = c(0, 0.5, 2)
sigma2_true = c(2)
error = c("normal", "heavy-tailed")

params_all = expand.grid(n = n,
                         n_sim = nsim,
                         beta_true = beta_true,
                         sigma2_true = sigma2_true,
                         error = error)

library(doParallel)
library(foreach)
library(here)

num_cores <- parallel::detectCores()
cl <- makeCluster(num_cores)
registerDoParallel(cl)

n_scenario <- nrow(params_all)
set.seed(262) 
seed_vector = floor(runif(nsim, 1, 10000))

final_all_scenarios <- foreach(
  scenario = 1:n_scenario, 
  .combine = 'rbind',
  .packages = c("dplyr", "here", "broom", "tidyverse"),
  .export = c("get_simdata", "bootstrap_t", "aggregate_results", "fit_model", "get_estimates")
) %dopar% {
  
  scenario_start_time <- Sys.time()
  params <- params_all[scenario, ]
  nsim_current <- params$n_sim
 
  results_list <- vector("list", nsim_current)
  
  for(i in 1:nsim_current){

    set.seed(scenario * 10000 + seed_vector[i])
    
    simdata <- get_simdata(
      n = params$n,
      beta_treat = params$beta_true,
      sigma2 = params$sigma2_true,
      error = params$error
    )
    

    res_method <- bootstrap_t(simdata, "y ~ x")
    

    results_list[[i]] <- data.frame(
      estimate = res_method$estimate,
      se = res_method$se,
      ci_lower = res_method$ci_lower,
      ci_upper = res_method$ci_upper,
      true_beta = params$beta_true
    )
  }
  

  scenario_end_time <- Sys.time()
  time_taken <- as.numeric(difftime(scenario_end_time, scenario_start_time, units = "mins"))
  
  scenario_df <- do.call(rbind, results_list)
  scenario_df$scenario <- scenario 
  
  file_name <- paste0("results_scen_", scenario, "_n", params$n, "_err_", params$error, "_parallel.rda")
  saveRDS(scenario_df, here::here("results", file_name))
  
  current_aggregate <- aggregate_results(scenario_df)
  current_aggregate$runtime_mins <- time_taken
  current_aggregate$scenario <- scenario 
  
  current_aggregate
}


stopCluster(cl)

saveRDS(final_all_scenarios, here::here("results/FINAL_SUMMARY_TABLE_parallel.rda"))

message("All scenarios finished in parallel.")
