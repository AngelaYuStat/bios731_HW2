
get_simdata = function(n, beta_treat, sigma2, gamma = 0, error = "normal"){
  beta0 = 1
  x = rbinom(n, 1, prob = 0.5)
  z = rnorm(n, mean = 1, sd = 2)
  if(error == "heavy-tailed")
  {
    u <- rt(n, df = 3)
    epsilon <- u * sqrt(2 * (3 - 2) / 3)
  }else{
    epsilon = rnorm(n, 0, sd = sqrt(sigma2))
  }
  y = beta0 + beta_treat * x + gamma * z + epsilon

  tibble(
    x = x,
    z = z,
    y = y
  )

}



