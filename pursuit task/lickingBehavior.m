%% Behavior figure

clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');
MaestroPath = 'C:\Users\Noga\Music\DATA';

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

behavior_params.time_after = 1500;
behavior_params.time_before = 2000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
windowEvent = -behavior_params.time_before:behavior_params.time_after;

cellID = [];
for ii = 186:length(cells)

    
    data = importdata(cells{ii});
    [data,flagCross] = getLicking(data,MaestroPath);
    
    if (~flagCross) 
        continue
    end
    
    for t=1:length(data.trials)
        
        ts = data.trials(t).rwd_time_in_extended + windowEvent;
        if data.trials(t).fail
            continue
        end 
        licks(t,:) = (data.trials(t).lick(ts)>5000);
        
        
    end
    
    figure;
    plot(windowEvent,mean(licks))
    title([num2str(data.info.cell_ID) ', ' data.info.session ])
    signalQuality = input('1- good signal,0-bad signal');
    task_info(lines(ii)).lick = signalQuality;
    if signalQuality
        cellID = [cellID data.info.cell_ID];
    end
    
    
end

save('C:\Users\Noga\Documents\Vermis Data\task_info','task_info');
%%

clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');
MaestroPath = 'C:\Users\Noga\Music\DATA';

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;
threshold = 5000;


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
    boolFail = [data.trials.fail];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    licks = nan(length(data.trials),length(windowEvent));
    for t=find(~boolFail)
        
        ts = data.trials(t).cue_onset +1000 + windowEvent;
        licks(t,:) = (data.trials(t).lick(ts)>threshold);
        
    end
    
    licksLow(ii,:) = nanmean(licks(indLow,:));
    licksHigh(ii,:) = nanmean(licks(indHigh,:));
    
    
end
    

aveLicksLow = mean(licksLow);
aveLicksHigh = mean(licksHigh);
semLicksLow = std(licksLow)/sqrt(length(cells));
semLicksHigh = std(licksHigh)/sqrt(length(cells));

figure;
errorbar(windowEvent,aveLicksLow,semLicksLow,'r'); hold on
errorbar(windowEvent,aveLicksHigh,semLicksHigh,'b')
xlabel('Time from cue')
ylabel('Fraction of trials with lick')

%% 
clear all
supPath =  'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');
MaestroPath = 'C:\Users\Noga\Music\DATA';

plot_cells =0;
req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;
threshold = 5000;


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
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowR = find (match_p == 25 & match_o == 1 &(~boolFail));
    indHighR = find (match_p == 75 & match_o == 1 & (~boolFail));
    indLowNR = find (match_p == 25 & match_o == 0 &(~boolFail));
    indHighNR = find (match_p == 75 & match_o == 0 &(~boolFail));
    
    licks = nan(length(data.trials),length(windowEvent));
    for t=find(~boolFail)
        
        ts = data.trials(t).rwd_time_in_extended + windowEvent;
        licks(t,:) = (data.trials(t).lick(ts)>threshold);
        
    end


    licksLowR(ii,:) = nanmean(licks(indLowR,:));
    licksHighR(ii,:) = nanmean(licks(indHighR,:));
    licksLowNR(ii,:) = nanmean(licks(indLowNR,:));
    licksHighNR(ii,:) = nanmean(licks(indHighNR,:));
    
    if plot_cells
        subplot(1,2,1)
        plot(windowEvent,licksLowR(ii,:),'r'); hold on
        plot(windowEvent,licksHighR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('Reward')
        
        subplot(1,2,2)
        plot(windowEvent,licksLowNR(ii,:),'r'); hold on
        plot(windowEvent,licksHighNR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('No Reward')
        
        
        pause
    end
end
    
%%
aveLicksLowR = mean(licksLowR);
aveLicksHighR = mean(licksHighR);
semLicksLowR = std(licksLowR)/sqrt(length(cells));
semLicksHighR = std(licksHighR)/sqrt(length(cells));
aveLicksLowNR = mean(licksLowNR);
aveLicksHighNR = mean(licksHighNR);
semLicksLowNR = std(licksLowNR)/sqrt(length(cells));
semLicksHighNR = std(licksHighNR)/sqrt(length(cells));

figure;
subplot(1,2,1)
errorbar(windowEvent,aveLicksLowR,semLicksLowR,'r'); hold on
errorbar(windowEvent,aveLicksHighR,semLicksHighR,'b')
xlabel('Time from Reward')
ylabel('Fraction of trials with lick')
title('Reward')
legend ('25','75')

subplot(1,2,2)
errorbar(windowEvent,aveLicksLowNR,semLicksLowNR,'r'); hold on
errorbar(windowEvent,aveLicksHighNR,semLicksHighNR,'b')
xlabel('Time from Reward')
ylabel('Fraction of trials with lick')
title('No Reward')
legend ('25','75')

    
    
