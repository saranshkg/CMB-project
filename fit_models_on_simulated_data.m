function [BIC, iBEST, BEST] = fit_models_on_simulated_data(a, r)
    
    [~, ~, BIC(1)] = fit_rw_updated(a, r);
    [~, ~, BIC(2)] = fit_rwck_updated(a, r);
    
    [M, iBEST] = min(BIC);
    BEST = BIC == M;
    BEST = BEST / sum(BEST);
end



function [Xfit, LL, BIC] = fit_rw_updated(a, r)
    obFunc = @(x) lik_rw_updated(a, r, x);
    
    X0 = randi([15, 60]);
    LB = 15;
    UB = 60;
    [Xfit, NegLL] = fmincon(obFunc, X0, [], [], [], [], LB, UB);
    
    LL = -NegLL;
    BIC = length(X0) * log(length(a)) + 2*NegLL;
end



function [Xfit, LL, BIC] = fit_rwck_updated(a, r)
    obFunc = @(x) lik_rwck_updated(a, r, x);
    
    X0 = randi([15, 60]);
    LB = 15;
    UB = 60;
    [Xfit, NegLL] = fmincon(obFunc, X0, [], [], [], [], LB, UB);
    
    LL = -NegLL;
    BIC = length(X0) * log(length(a)) + 2*NegLL;
end