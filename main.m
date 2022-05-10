%fprintf('\nSimulation\n')
%[sim_data_rw, sim_data_rwck] = simulate_models();

fprintf('\nParameter Recovery and Model Comparison\n')
CM = zeros(2);
nReps = 50;

for n=1:nReps
    fprintf('Rep %1.0f\n',n)
    [BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rw.choiceHistory_bets(n,:), sim_data_rw.rewardsObtained_wins(n,:));
    CM(1,:) = CM(1,:) + BEST;

    [BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rwck.choiceHistory_bets(n,:), sim_data_rwck.rewardsObtained_wins(n,:));
    CM(2,:) = CM(2,:) + BEST;
end