% Prerana Jain
% Computational Modelling of Behaviour
% Assignment 2 Problem 5
% Professor Apoorva Bhandari

%% Clear up the command window
clc; % clean the command window
clear; % clear workspace of all variables
close all
%% Validation

max_betaParm_RW = 8.578;
max_learnRate_RW = 0.331;
max_betaParm_CK = 8.574;
max_learnRate_CK = 0.331;

nTrials = 160;

% each subject
for s = 1:length(subjects)
    load(fullfile(rootFolder, sprintf('learnSub%1.0f.mat',subjects(s))));
    
    % 100 times
    for i = 1:100
        [actions, rewards] = Assignment1_Model3(54, [0.8, 0.2], learnRate, betaParm);
    end 
end



