function [Xfit_mean1, Xfit_mean2, X01, X02, BIC, iBEST, BEST] = fit_models_on_simulated_data(a, r)
     
    [~, ~, BIC(1),Xfit_mean1, X01] = fit_rw_updated(a, r);
    [~, ~, BIC(2),Xfit_mean2, X02] = fit_rwck_updated(a, r);
  
    [M, iBEST] = min(BIC);
    BEST = BIC == M;
    BEST = BEST / sum(BEST);
end
 
function [Xfit, LL, BIC, Xfit_mean,X0] = fit_rw_updated(a, r)
    for i = 1:160
        a(i) = a(i) + 1;
    end

    for i = 1:3
        obFunc = @(x) lik_rw_updated(a, r, x);
     
        X0 = randi([15, 60]);
        LB = 15;
        UB = 60;
        [Xfit(i), NegLL(i)] = fmincon(obFunc, X0, [], [], [], [], LB, UB);
    end
    
    Xfit_mean = mean(Xfit);
    NegLL_mean = mean(NegLL);

    disp("Fitting RW model: " + string(floor(X0)) + " -> " + string(floor(Xfit_mean)));
    
    LL = -NegLL;
    BIC = length(X0) * log(length(a)) + 2*NegLL_mean;
end

function [Xfit, LL, BIC, Xfit_mean,X0] = fit_rwck_updated(a, r)
    
    for i = 1:160
        a(i) = a(i) + 1;
    end
    
    for i=1:3
        obFunc = @(x) lik_rwck_updated(a, r, x);
        
        X0 = randi([15, 60]);
        LB = 15;
        UB = 60;
        [Xfit(i), NegLL(i)] = fmincon(obFunc, X0, [], [], [], [], LB, UB);
    end

    Xfit_mean = mean(Xfit);
    NegLL_mean = mean(NegLL);

    disp("Fitting RWCK model: " + string(floor(X0)) + " -> " + string(floor(Xfit_mean)));

    
    LL = -NegLL;
    BIC = length(X0) * log(length(a)) + 2*NegLL_mean;
end
