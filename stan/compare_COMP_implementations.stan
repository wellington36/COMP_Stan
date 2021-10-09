/* Compare a bunch of implementations for computing the (log) normalising constant for the Conway-Maxwell Poisson distribution */
functions{
  #include comp_pmf.stan
  #include robust_difference.stan
  #include asymp_approx.stan
  #include naive.stan
  #include brms.stan
  #include brms_bulk.stan
  #include adaptive.stan
}
data{
  real log_mu;
  real<lower=0> nu;
  real<lower=0> eps;
  int<lower=0> M;
  real true_value;
}
transformed data {
  real x_r[0];
  int x_i[0];
}
generated quantities {
  // Computing the (log) normalising constant
  real lZ_asymp = log_Z_COMP_Asymp(log_mu, nu);
  real lZ_naive[2] = log_Z_COMP_naive(log_mu, nu, eps, M);
  real lZ_brms[2] = log_Z_COMP_brms(log_mu, nu, eps, M);
  real lZ_brms_bulk[2] = log_Z_COMP_brms_bulk(log_mu, nu, eps, M);
  real lZ_adaptive[2] = log_Z_COMP_adaptive(log_mu, nu, eps, M, 0);
  real lZ_True = true_value;
  // Computing absolute differences (in natural space)
  real diff_asymp = robust_difference(true_value, lZ_asymp, 0);
  real diff_naive = robust_difference(true_value, lZ_naive[1], 0);
  real diff_brms = robust_difference(true_value, lZ_brms[1], 0);
  real diff_brms_bulk = robust_difference(true_value, lZ_brms_bulk[1], 0);
  real diff_adaptive = robust_difference(true_value, lZ_adaptive[1], 0);
  // Computing relative differences (in natural space)
  real rel_diff_asymp = robust_difference(true_value, lZ_asymp, 1);
  real rel_diff_naive = robust_difference(true_value, lZ_naive[1], 1);
  real rel_diff_brms = robust_difference(true_value, lZ_brms[1], 1);
  real rel_diff_brms_bulk = robust_difference(true_value, lZ_brms_bulk[1], 1);
  real rel_diff_adaptive = robust_difference(true_value, lZ_adaptive[1], 1);
  // Recording whether the target error was achieved
  int getItRight_asymp = (fabs(diff_asymp) < eps);
  int getItRight_naive = (fabs(diff_naive) < eps);
  int getItRight_brms = (fabs(diff_brms) < eps);
  int getItRight_brms_bulk = (fabs(diff_brms_bulk) < eps);
  int getItRight_adaptive = (fabs(diff_adaptive) < eps);
}

