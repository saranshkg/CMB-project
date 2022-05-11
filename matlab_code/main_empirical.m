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

figure(4); 
title('BIC values comparison for empirical data when fit on models:  RW vs RWCK')
hold on;
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
plot(BIC_emp_data(:,1), 'b', 'LineWidth',1.25);
hold on;
plot(BIC_emp_data(:,2), 'r', 'LineWidth',1.25);
legend({"Model 1: RW" + newline, "Model 2: RWCK"});
xlabel('Empirical Dataset #')	
ylabel('BIC Values')

[cpinc_emp] = model_free_analysis(nReps);

figure(5);
t = tiledlayout('flow','TileSpacing','compact');	
nexttile
title('Empirical change point (mean) vs Estimated change point (empirical data is fit on model: RW)')
hold on;
%plot(Xstart1, 'b', 'LineWidth',1.25);	
%hold on;	
plot(Xfit_mean1, 'g', 'LineWidth',1.25);	
hold on;	
plot (cpinc_emp, 'r', 'LineWidth',1.25);	
hold on;	
xlabel('Empirical Dataset #')	
ylabel('Change Point Occurence')

nexttile
title('Empirical change point (mean) vs Estimated change point (empirical data is fit on model: RWCK)')
hold on;
%plot (Xstart2, 'b', 'LineWidth',1.25);	
%hold on;	
plot (Xfit_mean2, 'g', 'LineWidth',1.25);	
hold on;	
plot (cpinc_emp, 'r', 'LineWidth',1.25);	
hold on;	
xlabel('Empirical Dataset #')	
ylabel('Change Point Occurence')	
lgd = legend ({"X-fit_{mean}" + newline, "cpinc_{emp}"});
lgd.Layout.Tile = 2;	
lgd.Layout.Tile = 'east';