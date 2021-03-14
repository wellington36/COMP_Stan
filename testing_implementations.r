library(cmdstanr)
library(rstan)
################
stanfit <- function(fit) rstan::read_stan_csv(fit$output_files())
source("testing_aux.r")
COMP_lpdf <- function(k, theta){
  lambda <- theta[1]
  nu <- theta[2]
  return(
    k * log(lambda) - nu*lfactorial(k)  
  )
}
#################
Mu <- 2000
Nu <- .5
Theta <- c(Mu, Nu)
Eps <- 1E-16
M <- 2E5
if(Nu == 1){
  TrueValue <- Mu  
}else{
  if(Nu == 2){
    TrueValue <- log(besselI(2*sqrt(Mu), nu = 0))
  }else{
    lps <- COMP_lpdf(k = 0:M, theta = Theta)
    TrueValue <- log_sum_exp(lps)
  }
}
## Should the approximation kick in ?
(log(Mu) * Nu >= log(1.5) && log(Mu) >= log(1.5))

implementations <- cmdstanr::cmdstan_model("stan/comp_implementations_testing.stan")

test.data <- list(
  log_mu = log(Mu),
  nu = Nu,
  eps = Eps,
  M = M
)

raw <- implementations$sample(data = test.data, chains = 1, 
                              iter_warmup = 0, iter_sampling = 1, fixed_param = TRUE, show_messages = TRUE)
results <- stanfit(raw)
out <- extract(results)
out$lp__ <- NULL

out
TrueValue

## Absolute error
robust_difference(TrueValue, out$lZ_approx_new)
robust_difference(TrueValue, out$lZ_brute_force_new)
robust_difference(TrueValue, out$lZ_approx_brms)
robust_difference(TrueValue, out$lZ_brute_force_brms)


relative_difference(TrueValue, out$lZ_approx_new)
relative_difference(TrueValue, out$lZ_brute_force_new)
relative_difference(TrueValue, out$lZ_approx_brms)
relative_difference(TrueValue, out$lZ_brute_force_brms)