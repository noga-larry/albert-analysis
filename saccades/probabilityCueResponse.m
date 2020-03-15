% Probability Cue Response
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

%% Make list of significant cells


req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;
req_params.grade = 10;
req_params.cell_type = 'CRB|PC';

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;
req_params.num_trials = 20;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells )
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    spikesLow = sum(rasterLow,1);
    spikesHigh = sum(rasterHigh,1);
    
    [p,h(ii)] = ranksum(spikesLow,spikesHigh);
    task_info(lines(ii)).cue_differentiating = h(ii);
    
    
    
end

save ('C:\noga\TD complex spike analysis\task_info','task_info');


%% PSTHs

supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;
%req_params.ID = [4243,4269,4575,4692,4718,4722]

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks =1;

comparisonWindow = raster_params.time_before + [100:300];
ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h = nan(length(cells),1);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    psthLow(ii,:) = raster2psth(rasterLow,raster_params);
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params);
    h(ii) = task_info(lines(ii)).cue_differentiating;
    
end


figure;
subplot(2,1,1)
ind = find(h);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Significant, n = ' num2str(length(ind))])

subplot(2,1,2)
ind = find(~h);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Not Significant, n = ' num2str(length(ind))])

figure;
ind = find(h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
ind = find(~h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
refline (1,0)

%% seperation to tails

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;
%req_params.ID = [4243,4269,4575,4692,4718,4722]

comparisonWindow = raster_params.time_before + [100:300];
ts = -raster_params.time_before:raster_params.time_after;
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h_left = nan(length(cells),1);
h_right = nan(length(cells),1);


raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.SD = 10;


for ii = 1:length(cells )
    data = importdata(cells{ii});
    
    raster_params.time_before = -100;
    raster_params.time_after = 700;
    raster_params.smoothing_margins = 0;
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    spikesLow = sum(rasterLow,1);
    spikesHigh = sum(rasterHigh,1);
    
    [p,h_left(ii)] = ranksum(spikesLow,spikesHigh,'tail','left');
    [p,h_right(ii)] = ranksum(spikesLow,spikesHigh,'tail','right');
    
    raster_params.time_before = 300;
    raster_params.time_after = 500;
    raster_params.smoothing_margins = 100;
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    psthLow(ii,:) = raster2psth(rasterLow,raster_params);
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params);


    
end

figure;
subplot(2,1,1)
ind = find(h_left);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Left, n = ' num2str(length(ind))])

subplot(2,1,2)
ind = find(h_right);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Right, n = ' num2str(length(ind))])


%% Significance as function of time

clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 50; % ms in each side

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before : raster_params.time_after;


HighTail = nan(length(cells),length(ts));
LowTail =nan(length(cells),length(ts));

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;
    
for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[ data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spksHigh = sum(rasterHigh(runningWindow,:));
        spksLow = sum(rasterLow(runningWindow,:)); 
        [~,HighTail(ii,t)] = ranksum(spksHigh,spksLow,'tail','right');
        [~,LowTail(ii,t)] = ranksum(spksHigh,spksLow,'tail','left');
    end
end
        
fracHighTail = mean(HighTail>0.05);
fracLowTail = mean(LowTail>0.05);    
figure;
plot(ts,fracHighTail,'b'); hold on
plot(ts,fracLowTail,'r')




