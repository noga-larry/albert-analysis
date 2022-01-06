%% Behavior figure

clear 

[task_info,supPath, MaestroPath,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss|BG|SNR';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

behavior_params.time_after = 1500;
behavior_params.time_before = 2000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
behavior_params.align_to = 'reward';

ts = -behavior_params.time_before:behavior_params.time_after;

cellID = [];
for ii = 390:length(cells)

    data = importdata(cells{ii});
    [data,flagCross] = getLicking(data,MaestroPath);
    
    if (~flagCross) 
        continue
    end
    
    ind = find(~[data.trials.fail]);
    licks = meanLicking(data,behavior_params,ind);
    
    plot(ts,licks)
    title([num2str(data.info.cell_ID) ', ' data.info.session ])
    signalQuality = input('1- good signal,0-bad signal');
    task_info(lines(ii)).lick = signalQuality;
    if signalQuality
        cellID = [cellID data.info.cell_ID];
    end
    
    
end

save(task_DB_path,'task_info');
%%

clear
PROBABILITIES = [25,75];
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
behavior_params.align_to = 'targetMovementOnset';

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    match_o = getPreviousOutcomes(data);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    for p = 1:length(PROBABILITIES)
        for j=1:2
            ind = find (match_p == PROBABILITIES(p) & ...
                (~boolFail) & match_o == j-1 );
            licks(ii,p,j,:) = meanLicking(data,behavior_params,ind);
        end
    end
    
end


%%
aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));
col = {'r','b'}
figure
for j=1:2
    subplot(2,1,j); hold on
    for i=1:length(PROBABILITIES)
        errorbar(ts,squeeze(aveLicks(i,j,:)),squeeze(semLicks(i,j,:)),col{i})
    end
    ylim([0,1])
    title(['Previous outcome: ' num2str(j-1)])
    xlabel(['Time from  ' behavior_params.align_to])
    ylabel('Fraction of trials with lick')
end


%% 
clear
PROBABILITIES = [25,75];
OUTCOMES = [0 1];
PLOT_CELLS = false;
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.ID = 5000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
behavior_params.align_to = 'reward';

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome(data);
    boolFail = [data.trials.fail];
    
    for p = 1:length(PROBABILITIES)
        for j=1:length(OUTCOMES)
            ind = find (match_p == PROBABILITIES(p)...
                & match_o == OUTCOMES(j) & (~boolFail));
            licks(ii,p,j,:) = meanLicking(data,behavior_params,ind);
        end
    end
    
    if PLOT_CELLS
        subplot(1,2,1)
        plot(ts,licksLowR(ii,:),'r'); hold on
        plot(ts,licksHighR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('Reward')
        
        subplot(1,2,2)
        plot(ts,licksLowNR(ii,:),'r'); hold on
        plot(ts,licksHighNR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('No Reward')
        
        
        pause
    end
end
    
%%

aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));

figure
subplot(2,1,1); hold on
errorbar(ts,squeeze(aveLicks(1,1,:)),squeeze(semLicks(1,1,:)),'r')
errorbar(ts,squeeze(aveLicks(2,1,:)),squeeze(semLicks(1,1,:)),'b') 
xlabel('Time from outcome')
ylabel('Fraction of trials with lick')
ylim([0 1])
title('NR')  

subplot(2,1,2); hold on
errorbar(ts,squeeze(aveLicks(1,2,:)),squeeze(semLicks(1,2,:)),'r')
errorbar(ts,squeeze(aveLicks(2,2,:)),squeeze(semLicks(2,2,:)),'b')  
xlabel('Time from outcome')
ylabel('Fraction of trials with lick')
ylim([0 1])
title('R') 


%% lick direcion dependency

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25,75];
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 5000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
behavior_params.align_to = 'targetMovementOnset';

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);
licks = nan(length(cells),length(PROBABILITIES),length(DIRECTIONS), length(ts));
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    match_o = getPreviousOutcomes(data);
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    for p = 1:length(PROBABILITIES)
       for d = 1: length(DIRECTIONS)
            ind = find (match_p == PROBABILITIES(p) & ...
                (~boolFail) & match_d == DIRECTIONS(d));
            licks(ii,p,d,:) = meanLicking(data,behavior_params,ind);
       end
    end
    
end

%%
aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));

col = {'r','b'};
figure;
for d = 1: length(DIRECTIONS)
    subplot(4,2,d); hold on
    for p = 1:length(PROBABILITIES)
        errorbar(ts,squeeze(aveLicks(p,d,:)),squeeze(semLicks(p,d,:)),col{p})
    end
    title(num2str(DIRECTIONS(d)))
    ylim([0 0.4])
end