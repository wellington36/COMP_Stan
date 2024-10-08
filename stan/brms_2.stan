/* Modified brms implementation with bug fixes and a bit of streamlining.*/
// Taken from https://github.com/paul-buerkner/brms/blob/master/inst/chunks/fun_com_poisson.stan
array[] real log_Z_COMP_brms2(real log_mu, real nu, real eps, int M) {
  real log_Z;
  int k = 2;
  real leps = log(eps);
  int converged = 0;
  int num_terms = 50;
  vector[num_terms + 1] log_Z_terms;
  int i = 1;
  if (nu == 1) {
    return {exp(log_mu), 0};
  }
  // nu == 0 or Inf will fail in this parameterization
  if (nu <= 0) {
    reject("nu must be positive");
  }
  if (nu == positive_infinity()) {
    reject("nu must be finite");
  }
  // first 2 terms of the series
  log_Z = log1p_exp(nu*log_mu);
  while (converged == 0) {
    if(k >= M) break;
    // adding terms in batches simplifies the AD tape
    i = 1;
    log_Z_terms[1] = log_Z;
    while (i <= num_terms) {
      log_Z_terms[i + 1] =  nu*(k * log_mu - lgamma(k + 1));
      k += 1;
      if (log_Z_terms[i + 1] <= leps) {
        converged = 1;
        break;
      }
      i += 1;
    }
    log_Z = log_sum_exp(log_Z_terms[1:i]);
  }
  return {log_Z, k};
}

