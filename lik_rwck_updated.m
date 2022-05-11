%cpinc = randi([15, 60]);
%NegLL = lik_rwck_updated1(a, r, cpinc);
%disp(NegLL);

function NegLL = lik_rwck_updated(a, r, cpinc)

nTrial = 160;
nOptions = 2;

% Reward probabilities
rProbs = [0.8 0.2];

%% Set up internal variables

% Learnrate for choice kernel and rescorla
learnRate_CK = 0.005;
learnRate = 0.004;

% Setting up stake, storing it
stake = [1 5 10 20 100];

% last reward values - LaRVa
larva_seven = NaN(7,1);

% setup for RW stuff
% set the initial values of all options to be equal
V = NaN(nTrial, nOptions);
V(1,:) = (1/nOptions)*zeros(1,nOptions);

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
        t = floor(t);
        if t > 160
            break
        end
        % Generating beta to mimic stake for both choice kernel and RW
        beta = randsample(stake,1);
        beta_CK = beta;

        % Combined probabilities of CK and RW
        denom = (exp(V(t, 1)*beta + beta_CK*CK(t, 1))) + (exp(V(t, 2)*beta + beta_CK*CK(t, 2)));
        p_1 = exp(beta*V (t, 1) + beta_CK*CK(t, 1))/ denom;
        p_2 = exp(beta*V (t, 2) + beta_CK*CK(t, 2))/ denom;

        if a(t) == 1
            choiceProb(t) = p_1;
        else
            choiceProb(t) = p_2;
        end

        %% Calculating action based on two parameters: stake and winning
        % Winning or losing on the last 7 trials is calculated cummulatively; model
        % learns on that basis

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

end

% compute negative log-likelihood
NegLL = -sum(log(choiceProb));
end