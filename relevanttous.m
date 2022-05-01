function choice = relevanttous(choiceProbs,nOptions) 
% Computational Modeling of Behavior 
% Ashoka University, Spring 2022
% Apoorva Bhandari

rChoice = rand;
choiceProbs = [0 choiceProbs];
choice = NaN; 

for i = 1:nOptions
    if rChoice<(sum(choiceProbs(1:i+1)))
        choice = i;
        break;
    end
end