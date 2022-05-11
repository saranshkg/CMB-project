fprintf('\nSimulation\n')
[sim_data_rw, sim_data_rwck] = simulate_models();

fprintf('\nParameter Recovery and Model Comparison\n')
CM = zeros(2);
nReps = 5;

for n=1:nReps
    figure(1); clf;
    FM = round(100*CM/sum(CM(1,:)))/100;
    t = imageTextMatrix(FM);
    set(t(FM'<0.3), 'color', 'w')
    hold on;
    [l1, l2] = addFacetLines(CM);
    set(t, 'fontsize', 10)
    title(['count = ' num2str(n)]);
    set(gca, 'xtick', [1:2], 'ytick', [1:2], 'fontsize', 12, ...
        'xaxislocation', 'top', 'tickdir', 'out')
    xlabel('fit model')
    ylabel('simulated model')

    drawnow

    fprintf('Rep %1.0f\n',n)
    [Xfit_mean_rw1(n), Xfit_mean_rwck1(n),Xstart_rw1(n), Xstart_rwck1(n), BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rw.choiceHistory_bets(n,:), sim_data_rw.rewardsObtained_wins(n,:));
    CM(1,:) = CM(1,:) + BEST;

    
    [Xfit_mean_rw2(n), Xfit_mean_rwck2(n), Xstart_rw2(n), Xstart_rwck2(n), BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rwck.choiceHistory_bets(n,:), sim_data_rwck.rewardsObtained_wins(n,:));
    CM(2,:) = CM(2,:) + BEST;
end


%% Title = Comparing optimal value of number of trials, after which changepoint occurs, with starting value from fmincon, along with the value from the simulated dataset

figure(2);

t = tiledlayout('flow','TileSpacing','compact');
nexttile
plot (Xstart_rw1, 'b', 'LineWidth',1.25);
hold on;
plot (Xfit_mean_rw1, 'r', 'LineWidth',1.25);
hold on;
plot (sim_data_rw.parameter_cp, 'k', 'LineWidth',1.25);
hold on;
xlabel('Trial Number')
ylabel('Change Point Occurance')

nexttile
plot (Xstart_rw2, 'b', 'LineWidth',1.25);
hold on;
plot (Xfit_mean_rw2, 'r', 'LineWidth',1.25);
hold on;
plot (sim_data_rwck.parameter_cp, 'k', 'LineWidth',1.25);
hold on;
xlabel('Trial Number')
ylabel('Change Point Occurance')

nexttile
plot (Xstart_rwck1, 'b', 'LineWidth',1.25);
hold on;
plot (Xfit_mean_rwck1, 'r', 'LineWidth',1.25);
hold on;
plot (sim_data_rw.parameter_cp, 'k', 'LineWidth',1.25);
hold on;
xlabel('Trial Number')
ylabel('Change Point Occurance')

nexttile
plot (Xstart_rwck2, 'b', 'LineWidth',1.25);
hold on;
plot (Xfit_mean_rwck2, 'r', 'LineWidth',1.25);
hold on;
plot (sim_data_rwck.parameter_cp, 'k', 'LineWidth',1.25);
hold on;
xlabel('Trial Number')
ylabel('Change Point Occurance')

lgd = legend ({"X_S_T_A_R_T" + newline, "X_F_I_T _M_E_A_N" + newline, "X_S_I_M_U_L_A_T_E_D _D_A_T_A "});
lgd.Layout.Tile = 4;
lgd.Layout.Tile = 'east';

%% 

figure(1); 
title('Confusion Matrix')
set(gcf, 'Position', [811   417   500   400])
set(gca, 'fontsize', 12);
C = confusionmat(CM(1,:),CM(2,:));
confusionchart(C);


function t = imageTextMatrix(M, xtl, ytl)

% M = rand(10,5);

imagesc(M)
for i = 1:size(M,1)
    for j = 1:size(M,2)
        t(j,i) = text(j,i, num2str(M(i,j)));
        set(t(j,i), 'horizontalalignment', 'center', ...
            'verticalalignment', 'middle');
    end
end
if exist('xtl') == 1
    set(gca, 'xtick', [1:length(xtl)], 'xticklabel', xtl)
end
if exist('ytl') == 1
    set(gca, 'ytick', [1:length(ytl)], 'yticklabel', ytl)
end
end

function [hx, hy] = addFacetLines(M)

% M = rand(10,5);
S = size(M);
lx = [0:S(2)]+0.5;
ly = [0:S(1)]+0.5;

for i = 1:length(lx)
    hx(i) = plot([lx(i) lx(i)], [0 S(1)]+0.5, 'k-');
end
for i = 1:length(ly)
    hy(i) = plot([0 S(2)]+0.5, [ly(i) ly(i)],  'k-');
end
xlim([0.5 S(2)+0.5])
ylim([0.5 S(1)+0.5])
end
