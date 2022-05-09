%% Cleanup
clc; % clean the command window
clear; % clear workspace of all variables
close all; % close any open figures

addpath(genpath('D:\g_drive\Career Documents\MA Liberal Studies\Coursework\Semester 2\Computational Modeling of Behaviour\Modeling Competition'))

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

choiceHistory = NaN(nReps, nTrials);
rewardsObtained = NaN(nReps, nTrials);

%% p(correct) analysis
param_names{1,1} = 'learning rate: \alpha';
param_names{1,2} = 'inverse temp: \beta';
param_names{2,1} = 'learning rate: \alpha';
param_names{2,2} = 'inverse temp: \beta';
param_names{2,3} = 'learning rate_c: \alphaC';
param_names{2,4} = 'inverse temp_c: \betaC';

fprintf('Model 1: %s\n', model_names{1});
parameters = NaN(nReps, 2);
for n = 1:nReps
    fprintf('Rep %1.0f\n',n)
    
    [a, r, learning_rate, inverse_temp] = simulate_rw_updated();
    %parameters(n, :) = [learning_rate inverse_temp];
    choiceHistory(n, :) = a;
    rewardsObtained(n, :) = r;
end

%data1.parameters = parameters;
data1.choiceHistory = choiceHistory;
data1.rewardsObtained = rewardsObtained;
save('D:\g_drive\Career Documents\MA Liberal Studies\Coursework\Semester 2\Computational Modeling of Behaviour\Modeling Competition\data1.mat', 'data1');


fprintf('Model 2: %s\n', model_names{2});
parameters = NaN(nReps, 4);
for n = 1:nReps
    fprintf('Rep %1.0f\n',n)
    
    [a, r, learning_rate, learning_rate_c, inverse_temp, inverse_temp_c] = simulate_rwck_updated();
    %parameters(n) = [learning_rate learning_rate_c inverse_temp inverse_temp_c];
    choiceHistory(n, :) = a;
    rewardsObtained(n, :) = r;
end

%data2.parameters = parameters;
data2.choiceHistory = choiceHistory;
data2.rewardsObtained = rewardsObtained;
save('D:\g_drive\Career Documents\MA Liberal Studies\Coursework\Semester 2\Computational Modeling of Behaviour\Modeling Competition\data2.mat', 'data2');




function [a_final, r, alpha, betaParm] = simulate_rw_updated()

    %% setting up the world
    
    nTrial = 160;
    Options = 2;
    
    % Reward probabilities of the two options, changepoint
    rProbs = [0.8 0.2];
    changepoint = randsample (rProbs,1);
    
    choicePolicy = 'softmax';
    
    % Caluclating values for Rescorla-Wagner
    V = NaN(nTrial, Options);
    V(1,:) = (1/Options)*zeros(1,Options); 
    
    % change starts from 0 and stores the changepoint values after update
    change = zeros(nTrial,1);
    
    % storing stake
    stake = [1 5 10 20 100];   
    storingstake = zeros(nTrial,1);
    
    % Starting with a set learning rate
    alpha = [0.05];
    choiceProb = zeros(nTrial, Options);
    
    % a (betting or not betting), r (winning or losing)
    a = zeros(nTrial,1); 
    a_final = zeros(nTrial,1); 
    r = NaN(nTrial,1); 
    
    % cpinc = changepoint incrementation, randomly changing every 15-60
    % trials. A better way to do this would be to make it choose between 15-60
    % again after every changepoint
    cpinc = randi([15,60]);
    
    %% Simulation
    
    % Changpoint is generated every 15-60 trials, determined by observing
    % participant data
    cpinc = randi([15,60]);
    
    % Hardstop for breaking the changepoint after 160 trials
    for i = 1:cpinc:160
        for t = i:(i+cpinc)
            if t > 160
                break
            end        
          
            % beta is mimicking stake
            betaParm = randsample(stake,1);
    
            % Storing changepoint
            change(t) = changepoint;
            % Storing stake
            storingstake(t) = betaParm;
            
    
            % compute choice probabilities
            choiceProb(t,:) = exp(V(t,:)*betaParm)/sum(exp(V(t,:)*betaParm));
            
            % deciding whether or not to take the bet
            a(t) = relevanttous(choiceProb(t,:),Options);
            a_final(t) = a(t) - 1;
            
            % generate reward based on choice, specified by set probabilities -
            % checking if it is lesser than the changepoint value (0.8 or 0.2)
            % only instead of randomizing each time.        
            r(t) = rand <= changepoint;
            
            % update values
            V(t+1,:) = V(t,:);
            delta = r(t)-V(t,a(t));
            V(t+1,a(t)) = V(t,a(t)) + alpha*delta;
                       
            % Stopping learnrate incrementation at 1
            if changepoint == 0.2
                if alpha <= 0.994
                    alpha = alpha + 0.006;
                end
            else
                alpha = alpha + 0.003;
            end
        end
           
        % Changing changepoint randomly
        if changepoint == 0.2
            changepoint = 0.8;
        else
            changepoint = 0.2;
        end    
    end
end





function [a_final, r, learnRate, learnRate_CK, beta, beta_CK] = simulate_rwck_updated()
    %% Cleanup
    %clc; % clean the command window
    %clear; % clear workspace of all variables
    %close all
    %% Set up experiment and world 
    nTrial = 160; 
    nOptions = 2;
    
    % Reward probabilities
    rProbs = [0.8 0.2];
    changepoint = randsample (rProbs,1);
    
    %% Set up internal variables
    
    % Learnrate for choice kernel and rescorla
    learnRate_CK = 0.005;
    learnRate = 0.004;
    
    % Setting up stake, storing it
    stake = [1 5 10 20 100];   
    storingstake = zeros(nTrial,1);
    
    % last reward values - LaRVa
    larva_seven = NaN(10,1);
    
    % Value of changepoint
    change = zeros(nTrial,1);
    
    % setup for RW stuff
    % set the initial values of all options to be equal
    V = NaN(nTrial, nOptions);
    V(1,:) = (1/nOptions)*zeros(1,nOptions); 
    
    % a (betting or not betting), r (winning or losing)
    a = zeros(nTrial,1);
    a_final = zeros(nTrial,1);
    r = NaN(nTrial,1);
    
    % Setup for Choice Kernel stuff
    % Setting the first values of Choice Kernal as zero
    CK = NaN(nTrial, nOptions);
    CK(1,:) = [0, 0];
    
    %% Simulation
    
    % Changpoint is generated every 15-60 trials, determined by observing
    % participant data
    cpinc = randi([15,60]);
    
    % Hardstop for breaking the changepoint after 160 trials
    for i = 1:cpinc:160
        for t = i:(i+cpinc)       
            if t > 160
                break
            end
            % Generating beta to mimic stake for both choice kernel and RW      
            beta = randsample(stake,1);
            beta_CK = beta;
            
            change(t) = changepoint;
            
            %Storing stake
            storingstake(t) = beta;
    
            % Combined probabilities of CK and RW
            denom = (exp(V(t, 1)*beta + beta_CK*CK(t, 1))) + (exp(V(t, 2)*beta + beta_CK*CK(t, 2)));
            p_1 = exp(beta*V (t, 1) + beta_CK*CK(t, 1))/ denom;
            p_2 = exp(beta*V (t, 2) + beta_CK*CK(t, 2))/ denom;
        
            % generate reward based on choice, specified by set probabilities -
            % checking if it is lesser than the changepoint value (0.8 or 0.2)
            % only instead of randomizing each time.        
            r(t) = rand <= changepoint;
            
    %% Calculating action based on two parameters: stake and winning    
    % Winning or losing on the last 7 trials is calculated cummulatively; model
    % learns on that basis
    
    % Caluclating action based on first 7 trials
    % we are controlling the random value generated for taking a bet. The
    % values of 0.89 and 0.11 have been generated through experimentation of
    % different values
            if t <= 7
                if beta >= 10
                    a(t) = find([-eps cumsum([p_1 p_2])] < (0.89 + 0.11*rand()), 1, 'last');
                    a_final(t) = a(t) - 1;
                else
                    a(t) = find([-eps cumsum([p_1 p_2])] < (0.11*rand()), 1, 'last');
                    a_final(t) = a(t) - 1;                
                end
            end
            
            % Learnrate incrementation
    
            % Cumulative score = cumul (score of winning)        
            cumul = 0;
    
            % r/beta        >=10               <10
            % Cumul >=4     LR + a(0.89)      LR + a(0.50)
            % Cumul <4      a(0.50)            a(0.11)
            % Based on a(0.xy). Cumulative sum of p1 and p2 is lesser than xy%
            % which means you take the bet xy% times. When the cumul is lesser
            % than 4, the model should not be incrementing learning        
            if t > 7
                for j = 1:7
                    larva_seven(j) = r(t-j);
                    cumul = cumul + larva_seven(j);
                end
    
                if cumul >= 4
                    if beta>=10
                        a(t) = find([-eps cumsum([p_1 p_2])] < (0.89 + 0.11*rand()), 1, 'last');
                        a_final(t) = a(t) - 1;
                    else
                        a(t) = find([-eps cumsum([p_1 p_2])] < (0.50*rand()), 1, 'last');
                        a_final(t) = a(t) - 1;
                    end
                    
                    % values of learnrate incrementation have been generated through experimentation of
                    % different values
                    if learnRate_CK <= 0.99998
                        learnRate_CK = learnRate_CK + 0.00002;
                    end       
                    
                    % values of learnrate incrementation have been generated through experimentation of
                    % different values
                    if learnRate <= 0.99996
                        learnRate = learnRate + 0.00004;
                    end
                else
                    if beta>=10
                        a(t) = find([-eps cumsum([p_1 p_2])] < (0.50*rand()), 1, 'last');
                        a_final(t) = a(t) - 1;
                    else
                        a(t) = find([-eps cumsum([p_1 p_2])] < (0.11*rand()), 1, 'last');
                        a_final(t) = a(t) - 1;
                    end
                end
            end
    %% Updating values of RW and CK
    
            % update values based on reward, using Rescorla Wagner update rule
            V(t+1,:) = V(t,:);
            V(t+1,a(t)) = V(t,a(t)) + learnRate*(r(t)-V(t,a(t)));
        
            % update choice kernel for 1st action
            % did we choose option 1 (ie. a(t) == 1)
            if (a(t) == 1)
    	        CK(t+1, 1) = CK(t,1) + learnRate_CK * (1 - CK(t,1));
            elseif (a(t) == 2)
    	        CK(t+1, 1) = CK(t,1) + learnRate_CK * (0 - CK(t,1));
            end
        
            % update choice kernel for 2nd action
            % did we choose option 2 (ie. a(t) == 2)
            if (a(t) == 2)
    	        CK(t+1, 2) = CK(t, 2) + learnRate_CK * (1 - CK(t, 2));
            elseif (a(t) == 1)
    	        CK(t+1, 2) = CK(t, 2) + learnRate_CK * (0 - CK(t, 2));
            end
        end
        
        % Changing changepoint after x iterations (x is determined randomly for
        % each subject)
        if changepoint == 0.2
            changepoint = 0.8;
        else
            changepoint = 0.2;
        end
        
    end
end