% The drawing of confusion matrix is borrowed/inspired from 
% the github codebase of 'Ten Simple Rules of Modeling Paper'

nReps = 50; % How many datasets do you want to fit to the models?
nIter = 3;  % How many times do you want to call the fmincon optimization function for calculating the mean optimal change point?

fprintf('\nLoading Empirical data\n');
[emp_data] = load_empirical_data(nReps);

fprintf('\nParameter Recovery and Model Comparison on empirical data\n')
BIC_emp_data = NaN(nReps, 2);

for n=1:nReps
    fprintf('Rep %1.0f\n',n)
    [Xfit_mean1(n), Xfit_mean2(n),Xstart1(n), Xstart2(n), BIC, iBEST, BEST] = fit_models_on_data(emp_data.choiceHistory_bets(n,:), emp_data.rewardsObtained_wins(n,:), nIter);
    BIC_emp_data(n, :) = BIC;
end

figure(5); 
title('BIC values comparison for empirical data');
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
plot(BIC_emp_data(:,1), 'b');
hold on;
plot(BIC_emp_data(:,2), 'r');
legend({"Model 1: RW" + newline, "Model 2: RWCK"});

[cpinc_emp] = model_free_analysis(nReps);

figure(6);
title('X values comparison for empirical data: RW');
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
%plot(Xstart1, 'b');
%hold on;
plot(Xfit_mean1, 'g');
hold on;
plot(cpinc_emp, 'r');
legend({"X-fit_{mean}" + newline, "cpinc_{emp}"});



figure(7);
title('X values comparison for empirical data: RWCK');
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
%plot(Xstart2, 'b');
%hold on;
plot(Xfit_mean2, 'g');
hold on;
plot(cpinc_emp, 'r');
legend({"X-fit_{mean}" + newline, "cpinc_{emp}"});