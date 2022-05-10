% ModellingChallenge
% Samarth Jain, Prerana Jain, Saransh Gupta, Anubhab Bhattacharya, Anusha Kaberwal
% Computational Modeling of Behavior 
% Ashoka University, Spring 2022

%% Clear up the command window
clc; % clean the command window
clear; % clear workspace of all variables
close all
%% Validation

max_betaParm_RW = 8.578;
max_learnRate_RW = 0.331;
max_betaParm_CK = 8.574;
max_learnRate_CK = 0.331;

subjects = zeros(50,1);
nTrials = 160;
for i = 1:50
    subjects(i) = i;
end

a_final = zeros(160, 50);
r = zeros(160, 50); 
learnRate = zeros(160, 50); 
learnRate_CK = zeros(160, 50); 
beta = zeros(160, 50);
beta_CK = zeros(160, 50); 

rootFolder = 'C:/Users/user/Desktop/Modelling_Challenge/ChallengeData';
% each subject
for s = 1:length(subjects)
    load(fullfile(rootFolder, sprintf('learnSub%1.0f.mat',subjects(s))));
    % 100 times
    %for i = 1
    [a_final(:,s), r(:,s), learnRate(:,s), learnRate_CK(:,s), beta(:,s), beta_CK(:,s)] = simulate_rwck_updated();
    %end 
    fprintf('completed %d\n',s)
end

%rootFolder = 'C:/Users/user/Desktop/Modelling_Challenge/SimulatedData';
% 
% for s = 1:length(subjects)
%     load(fullfile(rootFolder, sprintf('learnSub%1.0f.mat',subjects(s))));
%     % 100 times
%     %for i = 1
%     [a_final_s, r_s, learnRate_s, learnRate_CK_s, beta_s, beta_CK_s] = rwck_updated();
%     %end 
%     fprintf('completed %d\n',s)
% end
% 
