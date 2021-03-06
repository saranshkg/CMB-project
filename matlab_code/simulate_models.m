function [data1, data2] = simulate_models()
    %% Cleanup
    clc; % clean the command window
    clear; % clear workspace of all variables
    close all; % close any open figures
     
    % RW - Model 1, RW+CK - Model 2
    
    data1 = struct;
    data2 = struct;
    
    % model choice
    model_names = {'rw_updated', 'rw+ck_updated'};
    nReps = 50;
    % experiment parameters
    nTrials   = 160;    % number of trials
    mu  = [0.8 0.2];    % mean reward of bandits
    data.rProbs = mu;
    
    choiceHistory_bets = NaN(nReps, nTrials);
    rewardsObtained_wins = NaN(nReps, nTrials);
    
    %% p(correct) analysis
    param_names{1,1} = 'learning rate: \alpha';
    param_names{1,2} = 'inverse temp: \beta';
    param_names{2,1} = 'learning rate: \alpha';
    param_names{2,2} = 'inverse temp: \beta';
    param_names{2,3} = 'learning rate_c: \alphaC';
    param_names{2,4} = 'inverse temp_c: \betaC';
    
    fprintf('Model 1: %s\n', model_names{1});
    %parameters = NaN(nReps, 2);
    for n = 1:nReps
        fprintf('Rep %1.0f\n',n)
        cpinc = randi([40, 100]);
        [a, r, learning_rate, inverse_temp] = simulate_rw_updated(cpinc);
        %parameters(n, :) = [learning_rate inverse_temp];
        parameter_cp(n) = cpinc;
        choiceHistory_bets(n, :) = a;
        rewardsObtained_wins(n, :) = r;
    end
    
    data1.parameter_cp = parameter_cp;
    data1.choiceHistory_bets = choiceHistory_bets;
    data1.rewardsObtained_wins = rewardsObtained_wins;
    %save('C:\Users\user\Desktop\Modelling_Challenge\data1.mat', 'data1');
    
    fprintf('Model 2: %s\n', model_names{2});
    parameters = NaN(nReps, 4);
    for n = 1:nReps
        fprintf('Rep %1.0f\n',n)
        cpinc = randi([40, 100]);
        [a, r, learning_rate, learning_rate_c, inverse_temp, inverse_temp_c] = simulate_rwck_updated(cpinc);
        %parameters(n) = [learning_rate learning_rate_c inverse_temp inverse_temp_c];
        parameter_cp(n) = cpinc;
        choiceHistory_bets(n, :) = a;
        rewardsObtained_wins(n, :) = r;
    end
    
    data2.parameter_cp = parameter_cp;
    data2.choiceHistory_bets = choiceHistory_bets;
    data2.rewardsObtained_wins = rewardsObtained_wins;
    %save('C:\Users\user\Desktop\Modelling_Challenge\data2.mat', 'data2');
end