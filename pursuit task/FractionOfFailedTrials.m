%% Behavior figure

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

TASK = "both"; 
req_params = reqParamsEffectSize(TASK);

prob = [25, 75];

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

timeFailRelativeToMotion = cell(length(prob),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellID(ii) = data.info.cell_ID;

    tasks{ii} = data.info.task;

    [~,match_p] = getProbabilities (data);
    
    for p = 1:length(prob)
        
        boolFail = [data.trials.fail];
        ind = find (match_p == prob(p));
        fracFailed(ii,p) = 1 - mean([boolFail(ind)]);
        fracCompletedOnFirstTry(ii,p) = mean([data.trials(ind).previous_completed] & ...
           ~[boolFail(ind)]);
        
        endRelativeToMotion = [data.trials.trial_length] - [data.trials.movement_onset];
        timeFailRelativeToMotion{p} = [timeFailRelativeToMotion{p}, ...
            endRelativeToMotion(find(boolFail & match_p == prob(p)))];

    end

end

%%

figure;
aveFrac = mean(fracFailed);
semFrac = nanSEM(fracFailed);

subplot(2,2,1)
errorbar(prob,aveFrac,semFrac); hold on
ylabel('Frac successful trials')
p = signrank(fracFailed(:,1),fracFailed(1,2));
xlabel('Prob')
title(['Fail: p =' num2str(p) ', n =' num2str(length(cells))])

aveFrac = mean(fracCompletedOnFirstTry);
semFrac = nanSEM(fracCompletedOnFirstTry);

subplot(2,2,2)
errorbar(prob,aveFrac,semFrac); hold on
ylabel('Frac completed on first try trials')
p = signrank(fracCompletedOnFirstTry(:,1),fracCompletedOnFirstTry(1,2));
xlabel('Prob')
title(['First try: p =' num2str(p) ', n =' num2str(length(cells))])


subplot(2,1,2); hold on
plotHistForFC(timeFailRelativeToMotion{1},0:50:1500,'r')
plotHistForFC(timeFailRelativeToMotion{2},0:50:1500,'b')
legend('25', '75')
xlabel('Time from target motion')

sgtitle(TASK)

%%

unique_tasks = uniqueRowsCA(tasks')

c=1;
for i = 1:length(unique_tasks)
    ind = find(strcmp(tasks,unique_tasks{i}) & cellID<5001)

    subplot(length(unique_tasks),2,c)
    errorbar(prob, mean(fracCompletedOnFirstTry(ind,:)),nanSEM(fracCompletedOnFirstTry(ind,:))); hold on
    title(['Albert, ' unique_tasks{i} ],Interpreter="none")
    ylabel('Frac completed on first try trials')
    xlabel('Probability'); xticks(prob)

    c=c+1;

    ind = find(strcmp(tasks,unique_tasks{i}) & cellID>5000)

    subplot(length(unique_tasks),2,c)
    errorbar(prob, mean(fracCompletedOnFirstTry(ind,:)),nanSEM(fracCompletedOnFirstTry(ind,:))); hold on
    title(['Golda, ' unique_tasks{i} ],Interpreter="none")
    ylabel('Frac completed on first try trials')
    xlabel('Probability'); xticks(prob)

    c=c+1;

end