%% Cleanup
clc; % clean the command window
close all; % close any open figures

nSub = 50;

%% 
rootFolder = 'D:\g_drive\Career Documents\MA Liberal Studies\Coursework\Semester 2\Computational Modeling of Behaviour\Modeling Competition';
figure()
subjects = 1:nSub;
colorstring = 'rgbcmykrgb';
for s = 1:50
    load(fullfile(rootFolder, sprintf('ChallengeData\learnSub%1.0f.mat',subjects(s))))
    
    nTrials = size(datamat, 1);
    
    stay = NaN(1,nTrials-1); 
    prevrew = zeros(1,nTrials-1);
    
    for t = 2:nTrials
        if data.initial.choices(t) == data.initial.choices(t-1)
            stay(t-1) = 1; 
        else
            stay(t-1) = 0;
        end
        
        prevrew(t-1) = data.initial.rewards(t-1);    
    end
    
    plot( [0 1], [mean(stay(prevrew==-1)), mean(stay(prevrew==1)) ], ['o-' colorstring(s)], 'Linewidth', 2, 'MarkerSize', 25, 'MarkerFaceColor', colorstring(s), 'DisplayName', sprintf('sub%1.0f',subjects(s)))
    hold on 
end


xlabel('previous reward','FontSize',14)
xticks([0,1])
xticklabels({'0', '1'})
xlim([-0.05 1.05])
ylim([-0.1 1.1])
yticks([0,0.5,1])
yticklabels({'0','0.5', '1'})
ylabel('p(stay)','FontSize',20)
title('stay behavior', 'FontSize',20)
legend show
legend('Location', 'SouthEast')
ax = gca;
ax.FontSize = 14;


