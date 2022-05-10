%cpinc = randi([15, 60]);
%NegLL = lik_rwck_updated1(a, r, cpinc)

function NegLL = lik_rwck_updated(a, r, cpinc)

    disp("!!!");

    %% Set up experiment and world 
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
    
    

    % compute negative log-likelihood
    NegLL = 1;%-sum(log(choiceProb));
end
