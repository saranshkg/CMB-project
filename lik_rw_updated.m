<<<<<<< HEAD
%function NegLL = lik_rw_updated(a, r, cpinc)

nTrial = 160;
Options = 2;

% Reward probabilities of the two options, changepoint
rProbs = [0.8 0.2];
changepoint = randsample (rProbs,1);

choicePolicy = 'softmax';

% Caluclating values for Rescorla-Wagner
V = NaN(nTrial, Options);
V(1,:) = (1/Options)*zeros(1,Options);

% storing stake
stake = [1 5 10 20 100];

% Starting with a set learning rate
alpha = 0.05;
choiceProb = zeros(nTrial, Options);

%% Simulation
% Hardstop for breaking the changepoint after 160 trials
for i = 1:cpinc:160
    for t = i:(i+cpinc)
        if t > 160
            break
        end

        % beta is mimicking stake
        betaParm = randsample(stake,1);

        % compute choice probabilities
        p = exp(V(t,:)*betaParm)/sum(exp(V(t,:)*betaParm));
        
        % compute choice probability for actual choice
        choiceProb(t) = p(a(t));
    
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
            if alpha <= 0.997
                alpha = alpha + 0.003;
            end
        end
    end

    % Changing changepoint randomly
    if changepoint == 0.2
        changepoint = 0.8;
    else
        changepoint = 0.2;
    end
end

% compute negative log-likelihood
NegLL = -sum(log(choiceProb));
%end
=======
function NegLL = lik_rw_updated(a, r, alpha, beta)
    Q = [0.5 0.5];
    
    
    T = length(a);
    
    % loop over all trial
    for t = 1:T
        
        % compute choice probabilities
        p = exp(beta*Q) / sum(exp(beta*Q));
        
        % compute choice probability for actual choice
        choiceProb(t) = p(a(t));
        
        % update values
        delta = r(t) - Q(a(t));
        Q(a(t)) = Q(a(t)) + alpha * delta;
    
    end
    
    % compute negative log-likelihood
    NegLL = -sum(log(choiceProb));
end
>>>>>>> cd96c6b3e5c077ae53dd15405e2a4c140e946abf
