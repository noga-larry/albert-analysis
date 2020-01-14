%% cue

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;


lines = findLinesInDB(task_info,req_params);
fitInd = cellfun(@(c) c==0,{task_info(lines).extended_behavior_fit},'uni',false);
fitInd = [fitInd{:}];
fitInd = find(fitInd);
lines = lines(fitInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities(data);
    boolFail = [data.trials.fail];
    
    indLow = find(match_p == 25 & (~boolFail));
    indHigh = find(match_p == 75 & (~boolFail));
    
    saccades = nan(length(data.trials),length(windowEvent));
    for t = find(~boolFail)
        
        if data.trials(t).extended_trial_begin<1000
            continue
        end
        saccadeTrace = zeros(1,length(data.trials(t).extended_hVel));
        saccadeTrace(data.trials(t).extended_saccade_begin) = 1;
        ts = data.trials(t).cue_onset + data.trials(t).extended_trial_begin + windowEvent;
        saccades(t,:) = saccadeTrace(ts);
        
    end
    
    saccadesLow(ii,:) = gaussSmooth(nanmean(saccades(indLow,:)),behavior_params.SD);
    saccadesHigh(ii,:) = gaussSmooth(nanmean(saccades(indHigh,:)),behavior_params.SD);
    
    
end
    

aveLow = mean(saccadesLow);
aveHigh = mean(saccadesHigh);
semLow = std(saccadesLow)/sqrt(length(cells));
semHigh = std(saccadesHigh)/sqrt(length(cells));

figure;
errorbar(windowEvent,aveLow,semLow,'r'); hold on
errorbar(windowEvent,aveHigh,semHigh,'b')
xlabel('Time from cue')
ylabel('Fraction of trials with lick')

%% 
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;


lines = findLinesInDB(task_info,req_params);
fitInd = cellfun(@(c) isnumeric(c) && c==1,{task_info(lines).licking},'uni',false);
fitInd = [fitInd{:}];
fitInd = find(fitInd);
lines = lines(fitInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowR = find (match_p == 25 & match_o == 1 &(~boolFail));
    indHighR = find (match_p == 75 & match_o == 1 & (~boolFail));
    indLowNR = find (match_p == 25 & match_o == 0 &(~boolFail));
    indHighNR = find (match_p == 75 & match_o == 0 &(~boolFail));
    
    licks = nan(length(data.trials),length(windowEvent));
    for t=find(~boolFail)
        
        if data.trials(t).extended_trial_begin<1000
            continue
        end
        saccadeTrace = zeros(1,length(data.trials(t).extended_hVel));
        saccadeTrace(data.trials(t).extended_saccade_begin) = 1;
        ts = data.trials(t).rwd_time_in_extended + windowEvent;
        saccades(t,:) = saccadeTrace(ts);
        
    end
    
    LowR(ii,:) = gaussSmooth(nanmean(saccades(indLowR,:)),behavior_params.SD);
    HighR(ii,:) = gaussSmooth(nanmean(saccades(indHighR,:)),behavior_params.SD);
    LowNR(ii,:) = gaussSmooth(nanmean(saccades(indLowNR,:)),behavior_params.SD);
    HighNR(ii,:) = gaussSmooth(nanmean(saccades(indHighNR,:)),behavior_params.SD);
    
    
end
    
%%
aveLowR = mean(LowR);
aveHighR = mean(HighR);
semLowR = std(LowR)/sqrt(length(cells));
semHighR = std(HighR)/sqrt(length(cells));
aveLowNR = mean(LowNR);
aveHighNR = mean(HighNR);
semLowNR = std(LowNR)/sqrt(length(cells));
semHighNR = std(HighNR)/sqrt(length(cells));

figure;
errorbar(windowEvent,aveLowR,semLowR,'r'); hold on
errorbar(windowEvent,aveHighR,semHighR,'b')
xlabel('Time from Reward')
ylabel('Fraction of trials')
title('Reward')
errorbar(windowEvent,aveLowNR,semLowNR,'c'); hold on
errorbar(windowEvent,aveHighNR,semHighNR,'k')
legend ('25R','75R','25NR','75NR')

    
    
