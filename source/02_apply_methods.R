
fit_model = function(simulated_data, model){
  lm(model, data = simulated_data)
}

get_estimates = function(model_fit){
  
  stats = tidy(model_fit, conf.int = TRUE) %>%
    filter(term == "x") %>%
    select(estimate, std.error, conf.low, conf.high)
  
  return(list(beta_hat = stats$estimate, se = stats$std.error, ci_upper = stats$conf.high, ci_lower = stats$conf.low))
}

bootstrap_t = function(data, model, B = 500, B_inner = 100, alpha = 0.05){
  # 1. Fit the initial model
  y_vec <- data$y
  x_mat <- model.matrix(as.formula(model), data = data)
  target_col <- "x"
  model_fit = fit_model(data, model)
  estimate = get_estimates(model_fit)$beta_hat
  se = get_estimates(model_fit)$se
  
  t_vec = numeric(B) 
  
  for(i in 1:B){
    # 2. First level of bootstrap for theta_hat
    idx_b = sample(1:nrow(data), size = nrow(data), replace = TRUE)
    y_b = y_vec[idx_b]
    x_b = x_mat[idx_b, , drop = FALSE]
    fit_b = lm.fit(x_b, y_b)
    estimate_b = fit_b$coefficients[target_col]
    
    # 3. Second level of Bootstrap for se_hat(theta_hat)
    est_b_inner_vec = numeric(B_inner)
    for(j in 1:B_inner){
      idx_inner = sample(1:nrow(x_b), size = nrow(x_b), replace = TRUE)
      fit_inner = lm.fit(x_b[idx_inner, , drop = FALSE], y_b[idx_inner])
      est_b_inner_vec[j] = fit_inner$coefficients[target_col]
    }
    
    # 4. t statistics
    se_b = sd(est_b_inner_vec, na.rm = TRUE)
    t_vec[i] = (estimate_b - estimate) / se_b # (theta_hat_star - theta_hat) / se_star
  }
  
  # 5. calculate critical number
  t_lower = quantile(t_vec, 1 - alpha/2, na.rm = TRUE)
  t_upper = quantile(t_vec, alpha/2, na.rm = TRUE)
  
  ci_lower = estimate - t_lower * se
  ci_upper = estimate - t_upper * se
  
  return(list(estimate = estimate, se = se, ci_upper = ci_upper, ci_lower = ci_lower))
}

bootstrap_percentile = function(data, model, B = 500, alpha = 0.05){
  # 1. Fit the initial model
  y_vec <- data$y
  x_mat <- model.matrix(as.formula(model), data = data)
  target_col <- "x"
  model_fit = fit_model(data, model)
  estimate = get_estimates(model_fit)$beta_hat
  se = get_estimates(model_fit)$se
  
  estimate_b = numeric(B) 
  
  for(i in 1:B){
    # 2. bootstrap for theta_hat
    idx_b = sample(1:nrow(data), size = nrow(data), replace = TRUE)
    y_b = y_vec[idx_b]
    x_b = x_mat[idx_b, , drop = FALSE]
    fit_b = lm.fit(x_b, y_b)
    estimate_b[i] = fit_b$coefficients[target_col]
  }
  
  # 3. calculate confidence intervals by percentile method
  ci_lower = quantile(estimate_b, probs = alpha/2, na.rm = TRUE)
  ci_upper = quantile(estimate_b, probs = 1 - alpha/2, na.rm = TRUE)
  
  return(list(estimate = estimate, se = se, ci_upper = ci_upper, ci_lower = ci_lower))
}

wald_CI = function(data, model){
  # 1. Fit the model
  model_fit = fit_model(data, model)
  results = get_estimates(model_fit)
  estimate = results$beta_hat
  se = results$se
  
  # 2. get confidence intervals by wald
  ci_lower = results$ci_lower
  ci_upper = results$ci_upper
  
  return(list(estimate = estimate, se = se, ci_upper = ci_upper, ci_lower = ci_lower))
}
