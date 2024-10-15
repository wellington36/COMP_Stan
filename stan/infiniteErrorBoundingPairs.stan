functions{
  array[] real infiniteErrorBoundingPairs(array[] real p, real epsilon, int maxIter, int n0) {
    vector[maxIter + 1] storeVal;
    real leps = log(epsilon);
    int n = 2;
    int n0_ = n0;

    // Setting up first iterations
    storeVal[1] = logFunction(n0_, p);
    n0_ += 1;
    storeVal[2] = logFunction(n0_, p);
  
    // Find the maximum
    while (storeVal[n] > storeVal[n - 1]) {
      n0_ += 1;
      n += 1;
      storeVal[n] = logFunction(n0_, p);
      if (n >= maxIter) return({log_sum_exp(storeVal[:n]), 1. * n}); // Return if maxIter is reached
    }
  
    while (storeVal[n] - log(-expm1(storeVal[n] - storeVal[n - 1])) >= leps + log2()) {
      n0_ += 1;
      n += 1;
      storeVal[n] = logFunction(n0_, p);
      if (n >= maxIter) break;
    }
  
    storeVal[n + 1] = storeVal[n] - log(-expm1(storeVal[n] - storeVal[n - 1])) - log2();
    return {log_sum_exp(sort_asc(storeVal[:(n + 1)])), 1. * n};
    };
}