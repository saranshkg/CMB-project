% ModellingChallenge
% Samarth Jain, Prerana Jain, Saransh Gupta, Anubhab Bhattacharya, Anusha Kaberwal
% Computational Modeling of Behavior
% Ashoka University, Spring 2022

function [a_final, r, learnRate, learnRate_CK, beta, beta_CK] = simulate_rwck_updated(cpinc)
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
larva_seven = NaN(7,1);

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
%cpinc = randi([15,60]);

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
%% Ex-Existential Crisis:

% Find RANDOM INTEGER VALUE in a range - done
% cpinc = randi([,]) - returns an integer value instead of a matrix of the same size

%% Our interpretation

% stake (beta/inverse temp), Learning rate (alpha), winning/losing (r), betting/not betting (a), change point (change)
% Our interpretation: with RW, changpoint should eventually change betting
% behaviour. More than winning/losing it should be dependent on stake (this is just for RW)
% inturn betting should be dependent on winning/losing (because winning
% is dependent on changepoint (this is just for CK))

% Changepoint detection is done through whether or not you are winning
% previously. As soon as you start winning or losing a lot, model/subject
% recognizes some change. We control for this by looking at last 7 trials
% the reason CK is using last 7 trials is because realistically the working
% memory can store only +- 7 items in the digit span. As the response time
% for each trial is lesser than 3.5 seconds, the subjects may not be able
% to remember whether they won or not beyond the last 7 trials.

% Model 2 = Adaptation of Rescorla-Wagner+Choice Kernel.
% Route two: Betting based on stake, changepoint and changepoint detection through winning or losing
% value to maximize points. Betting behaviour is more controlled

%% Problems:

% are they actually changing their betting behavior or not based on
% learnrate? are they actually using learnrate to change this? - done

% Is 5 a small number for trial incrementing?

% find optimal learnrates for all 4 places

% why is incremental of learnrate resulting in more fear (so model is scared
% of taking bets)

% Make change point values impact winning [change is impacting (r)] - done

% Correlate storingstake to betting - done
% Correlate betting to winning - done

% find a way to choose cpinc randomly - done

% store a as 0 and 1 - done in a_final

% rn model is not considering past betting behaviour, past winnings and current stake for action.
% It is taking more bets when its 1 than when its 100 (even when rProb is 0.8) - done, solved this using
% added weightage for stake above 10.