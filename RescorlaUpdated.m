% Computational Modeling of Behaviour, Spring 2022
% function [a, r] = Model3(Trial, rProbs, learnRate, beta) 
%%
clc; % clean the command window
clear; % clear workspace of all variables
close all
%%
% number of trials, 
nTrial = 160;
Options = 2; % There are only two possible options

% Reward probabilities of the two options
rProbs = [0.8 0.2];
changepoint = randsample (rProbs,1);

choicePolicy = 'softmax';

V = NaN(nTrial, Options);
V(1,:) = (1/Options)*zeros(1,Options); 

change = zeros(nTrial,1);

stake = [1 5 10 20 100];   
storingstake = zeros(nTrial,1);

alpha = [0.02];
choiceProb = zeros(nTrial, Options);
a = zeros(nTrial,1); %using alpha for betting/not betting
r = NaN(nTrial,1); %using this for winning or losing
    
%cpinc = randn(15,60); add a hardstop of 160
cpinc = 40;
for i = 1:cpinc:160
    %cpinc = rand(15,60);
    for t = i:(i+cpinc)
        if t > 160
            break
        end
        
        betaParm = randsample(stake,1); %create array with {1,5,10,20,100} and choose randomly. This mimics stake 
        
        % compute choice probabilities
        choiceProb(t,:) = exp(V(t,:)*betaParm)/sum(exp(V(t,:)*betaParm));
        
        % deciding option
        a(t) = relevanttous(choiceProb(t,:),2);
        
        % generate reward based on choice
        r(t) = rand < rProbs(a(t));
        
        % update values
         V(t+1,:) = V(t,:);
         delta = r(t)-V(t,a(t));
         V(t+1,a(t)) = V(t,a(t)) + alpha*delta;
         
         %Storing changepoint
         change(t) = changepoint;
         %Storing stake
         storingstake(t) = betaParm;
                  
        %put hard stop at 1
        if alpha <= 0.994
            alpha = alpha + 0.006;
        end
    end
       
    % Changing changepoint randomly
    if changepoint == 0.2
        changepoint = 0.8;
    else
        changepoint = 0.2;
    end    
end

%stake (beta), Learning rate (alpha), winning/losing (r), betting/not betting (a), change point (change)
