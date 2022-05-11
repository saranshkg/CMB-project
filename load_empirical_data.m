function [emp_data] = load_empirical_data(nReps)

    emp_data = struct;
    
    for n=1:nReps
        emp_data_per_sub = load('D:\g_drive\Career Documents\MA Liberal Studies\Coursework\Semester 2\Computational Modeling of Behaviour\Modeling Competition\ChallengeData\learnSub' + string(n) + '.mat');
        choiceHistory_bets(n, :) = emp_data_per_sub.datamat(:,4);
        rewardsObtained_wins(n, :) = emp_data_per_sub.datamat(:,5);
        rewardProb_cp(n, :) = emp_data_per_sub.datamat(:,7);
    end
    
    emp_data.choiceHistory_bets = choiceHistory_bets;
    emp_data.rewardsObtained_wins = rewardsObtained_wins;
    emp_data.rewardProb_cp = rewardProb_cp;

end