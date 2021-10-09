functions{
  #include comp_pmf.stan
  #include infiniteAdaptive.stan
}
data{
  int<lower=0> K;
  int<lower=0> n[K];
  int<lower=0> y[K];
  int<lower=0> N;
  real<lower=0> s_mu;
  real<lower=0> r_mu;
  real<lower=0> nu_sd;
  real<lower=0> eps;
  int<lower=0> M;
}
transformed data{
  real logL = log(0);
}
parameters{
  real mu;
  real<lower=0> nu;
}
transformed parameters{
  real log_mu = log(mu);
  real log_norm_const[2] = infiniteAdaptive({log_mu, nu}, eps, M, logL, 0);
}
model{
  mu ~ gamma(s_mu, r_mu);
  nu ~ normal(0, nu_sd);
  // Likelihood
  for(k in 1:K){
    target += n[k] * COM_Poisson_lpmf(y[k] | log_mu, nu, log_norm_const[1]);
  } 
}
generated quantities{
  real n_iter = log_norm_const[2];
}