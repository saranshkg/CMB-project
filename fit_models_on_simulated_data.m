function [BIC, iBEST, BEST] = fit_models_on_simulated_data(a, r)
    
    [~, ~, BIC(1)] = fit_rw_updated(a, r);
    [~, ~, BIC(2)] = fit_rwck_updated(a, r);
    
    [M, iBEST] = min(BIC);
    BEST = BIC == M;
    BEST = BEST / sum(BEST);
end


function [Xfit, LL, BIC] = fit_rw_updated(a, r)
    for i = 1:160
        a(i) = a(i) + 1;
    end
    for i = 1:100
        obFunc = @(x) lik_rw_updated(a, r, x);
        
        X0 = randi([15, 60]);
        LB = 15;
        UB = 60;
        [Xfit,NegLL,flag,out,lambda,grad,hess] = fmincon(obFunc, X0, [], [], [], [], LB, UB);
    
        LL = -NegLL;
        BIC = length(X0) * log(length(a)) + 2*NegLL;
    end
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
