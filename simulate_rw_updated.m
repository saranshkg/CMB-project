% ModellingChallenge
% Samarth Jain, Prerana Jain, Saransh Gupta, Anubhab Bhattacharya, Anusha Kaberwal
% Computational Modeling of Behavior 
% Ashoka University, Spring 2022

function [a_final, r, alpha, betaParm] = simulate_rw_updated(cpinc)
    %% Cleanup
    %clc; % clean the command window
    %clear; % clear workspace of all variables
    %close all

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
    alpha = 0.05;
    choiceProb = zeros(nTrial, Options);
    
    % a (betting or not betting), r (winning or losing)
    a = zeros(nTrial,1); 
    a_final = zeros(nTrial,1); 
    r = NaN(nTrial,1); 
    
    % cpinc = changepoint incrementation, randomly changing every 15-60
    % trials. A better way to do this would be to make it choose between 15-60
    % again after every changepoint
    %cpinc = randi([15,60]);
    %cpfirst = cpinc;
    %% Simulation
      
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
        %cpinc = randi([cpfirst-5,cpfirst+5]);

    end
end

% stake (beta/inverse temp), Learning rate (alpha), winning/losing (r), betting/not betting (a), change point (change)
% Model 1 = Adaptation of Rescorla-Wagner.
% Route one: Betting based on stake value to maximize points
% This model uses stake to influence betting behaviour, not changepoint or winning/losing. Hence, inverse 
% temperature is able to mimic stake well wherein it gives more weightage to higher stakes than lower ones,
% while still introducing noise through softmax

%TO-DO
%simulation - done
%likelihood functions - 2 models
%parameter recovery
%model recovery/BIC calculation/confusion matrix
%data validation - model fitting