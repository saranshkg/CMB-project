% Computational Modeling of Behavior 
% Ashoka University, Spring 2022

% function [a, r] = Assignment1_Model5(nTrial, rProbs, learnRate, beta, learnRate_CK, beta_CK) 
%%
clc; % clean the command window
clear; % clear workspace of all variables
close all
%% Set up experiment and world 
nTrial = 160; 
nOptions = 2;

% Reward probabilities
rProbs = [0.8 0.2];
changepoint = randsample (rProbs,1);

%% Set up internal variables

% learning rate and softmax temperature as free parameters for
% Choice-Kernel
learnRate_CK = 0.005; %step increments to be added

stake = [1 5 10 20 100];   
storingstake = zeros(nTrial,1);

% learning rate and softmax temperature as free parameters for
% Rescorla-Wargner
learnRate = 0.004;

larva_five = NaN(40,1);
change = zeros(nTrial,1);

% setup for RW stuff
% set the initial values of all options to be equal
V = NaN(nTrial, nOptions);
V(1,:) = (1/nOptions)*zeros(1,nOptions); 

a = zeros(nTrial,1); %still using alpha for betting/not betting
r = NaN(nTrial,1); %still using this for winning or losing

% Setup for Choice Kernel stuff
% Setting the first values of Choice Kernal as zero
CK = NaN(nTrial, nOptions);
CK(1,:) = [0, 0];

%% Simulation
%cpinc = round(randn(15,60));% add a hardstop of 160
cpinc = 40;
for i = 1:cpinc:160
    for t = i:(i+cpinc)
        if t > 160
            break
        end

        beta = randsample(stake,1);
        beta_CK = beta;
        
        % Combined probabilities
        denom = (exp(V(t, 1)*beta + beta_CK*CK(t, 1))) + (exp(V(t, 2)*beta + beta_CK*CK(t, 2)));
        p_1 = exp(beta*V (t, 1) + beta_CK*CK(t, 1))/ denom;
        p_2 = exp(beta*V (t, 2) + beta_CK*CK(t, 2))/ denom;
    
        % make choice according to choice probababilities
        % a(t) = choose([p1 p2]);
        a(t) = find([-eps cumsum([p_1 p_2])] < rand, 1, 'last' );   
    
        % generate reward based on choice, specified by set probabilities
        r(t) = rand < rProbs(a(t));

        %Learnrate incrementation
        cumul = 0;
        if t > 40
            for j = 1:40
                %replaceval = t-j;
                larva_five(j) = r(t-j);
                cumul = cumul + larva_five(j);
            end
        end
        if cumul >= 7
            if learnRate_CK <= 0.9998
                learnRate_CK = learnRate_CK + 0.0002;
            end            
            %Check whether the rates of learning must be the same or not.
            if learnRate <= 0.9997
                learnRate = learnRate + 0.0004;
            end
        end

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
        change(t) = changepoint;
        %Storing stake
        storingstake(t) = beta;
    end
    
    % Changing changepoint randomly
    if changepoint == 0.2
        changepoint = 0.8;
    else
        changepoint = 0.2;
    end
    
end

%Existential Crisis:
%Find RANDOM INTEGER VALUE in a range

% RW_CK problems:
%make (a) store it as 0 and 1
%are they actually changing their betting behavior or not based on
%learnrate? are they actually using learnrate to change this?
%Is 5 a small number for trial incrementing?
%find optimal learnrates for all 4 places
%Our interpretation: with RW, changpoint should eventually change betting
%behaviour. More than winning/losing it should be dependent on stake (this is just for RW)
%inturn betting should be dependent on winning/losing (because winning
%is dependent on changepoint (this is just for CK)
%why is incremental of learnrate resulting in more fear so model is scared
%of taking bets

% Rescorla Problems:
%change point values dont impact winning [change is not impacting (r)]
%storingstake not corrwlated ot betting
%betting not correlated to winning
% find a way to choose cpinc randomly
% add hardstop to cpinc at 160
% store a as 0 and 1
% rn model is reversing betting, winning and stake. It is taking more bets
% when its 1 than when its 100 (even when rProb is 0.8)