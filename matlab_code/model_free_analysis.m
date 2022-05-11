function [cpinc_emp] = model_free_analysis(nReps)

fprintf('\nLoading Empirical data\n');
[emp_data] = load_empirical_data(nReps);

cpinc_emp = zeros(nReps, 1);

for n = 1:nReps
    rewardProb = emp_data.rewardProb_cp(n,:);
    cp = [];
    cp_diff = [];

    for i = 1:159
        if rewardProb(i) ~= rewardProb(i+1)
            cp = [cp; i+1];
        end
    end
    
    cp_diff = [cp(1)];
    for i = 1:size(cp,1) - 1
        cp_diff = [cp_diff; cp(i+1) - cp(i)];
    end

    cpinc_emp(n) = mean(cp_diff);
            
end

figure(6);
title('Model free analysis: Empirical change point (mean)')
hold on;
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
plot(cpinc_emp, 'r', 'LineWidth',1.25);
%legend({"Model 1: RW" + newline, "Model 2: RWCK"});
xlabel('Empirical Dataset #')	
ylabel('Change Point Occurence')

end

