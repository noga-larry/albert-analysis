%% Behavior figure

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks =0;

prob = [25, 75];

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    
    for p = 1:length(prob)
        
        ind = find (match_p == prob(p));
        fracFailed(ii,p) = 1 - mean([data.trials(ind).fail]);
        fracCompletedOnFirstTry(ii,p) = mean([data.trials(ind).previous_completed] & ...
           ~[data.trials(ind).fail]);

    end

end

%%

figure;
aveFrac = mean(fracFailed);
semFrac = std(fracFailed)/sqrt(length(cells));

subplot(1,2,1)
errorbar(prob,aveFrac,semFrac); hold on
ylabel('Frac successful trials')
xlabel('Prob')
title('Fail')

aveFrac = mean(fracCompletedOnFirstTry);
semFrac = std(fracCompletedOnFirstTry)/sqrt(length(cells));

subplot(1,2,2)
errorbar(prob,aveFrac,semFrac); hold on
ylabel('Frac completed on first try trials')
xlabel('Prob')
title('First try')
