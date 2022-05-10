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
    [BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rw.choiceHistory_bets(n,:), sim_data_rw.rewardsObtained_wins(n,:));
    CM(1,:) = CM(1,:) + BEST;
    
    [BIC, iBEST, BEST] = fit_models_on_simulated_data(sim_data_rwck.choiceHistory_bets(n,:), sim_data_rwck.rewardsObtained_wins(n,:));
    CM(2,:) = CM(2,:) + BEST;
end

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
