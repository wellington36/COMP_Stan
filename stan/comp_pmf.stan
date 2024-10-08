/* Conway-Maxwell Poisson probability mass function */ 
real log_COM_Poisson(int k, real log_mu, real nu){
    return k * log_mu - nu * lgamma(k + 1);
}
real COM_Poisson_lpmf(int k, real log_mu, real nu, real logZ){
    return k * log_mu - nu * lgamma(k + 1) - logZ;
}
real logFunction(int n, array[] real p){
  return log_COM_Poisson(n, p[1], p[2]);
}