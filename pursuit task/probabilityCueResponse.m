% Probability Cue Response
clear; clc
[task_info, supPath ,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

% Make list of significant cells

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;
req_params.grade =7;
req_params.ID = 4000:6000;
req_params.cell_type = 'PC|CRB';
req_params.num_trials = 50;
req_params.remove_repeats = 0;


raster_params.align_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells )
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    spikesLow = sum(rasterLow,1);
    spikesHigh = sum(rasterHigh,1);
    
    [p,h(ii)] = ranksum(spikesLow,spikesHigh);
    task_info(lines(ii)).cue_differentiating = h(ii);
    
    
end

save (task_DB_path,'task_info')


%% PSTHs

clear 
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis');


req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
% req_params.ID = setdiff(4000:5000,[4220,4273,4316,4331,4333,4348,4582,...
%     4785,4802,4810,4841,4845,4862,4833,...
%     4907]);
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
%req_params.ID = [4243,4269,4575,4692,4718,4722]

raster_params.align_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparisonWindow = raster_params.time_before + [100:400];

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h = nan(length(cells),1);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
   
    [~,match_p] = getProbabilities (data);
    boolSaccades = isTrailWIthSaccade(data,'cue',-200,500);

    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    indBaseline = find(~boolFail);
    
    rasterBaseline = getRaster(data,indBaseline,raster_params);
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    if ~strcmp(req_params.cell_type,'PC cs')
         baseline = mean(raster2psth(rasterBaseline,raster_params));
    else 
        baseline = 0;
    end
    psthLow(ii,:) = raster2psth(rasterLow,raster_params)-baseline;
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params)-baseline;
    h(ii) = task_info(lines(ii)).cue_differentiating;
    
end


f = figure; f.Position = [10 80 700 500];
subplot(3,1,1)
ind = find(h);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Significant, n = ' num2str(length(ind))])

subplot(3,1,2)
ind = find(~h);
aveLow = mean(psthLow(ind,:));
semLow = std(psthLow(ind,:))/sqrt(length(ind));
aveHigh = mean(psthHigh(ind,:));
semHigh = std(psthHigh(ind,:))/sqrt(length(ind));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Not Significant, n = ' num2str(length(ind))])


subplot(3,1,3)
aveLow = mean(psthLow);
semLow = std(psthLow)/sqrt(length(cells));
aveHigh = mean(psthHigh);
semHigh = std(psthHigh)/sqrt(length(cells));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['All, n = ' num2str(length(cells))])

f = figure; f.Position = [10 80 700 500];
ind = find(h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
ind = find(~h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
refline (1,0)

 p = signrank (mean(psthHigh(:,comparisonWindow),2),mean(psthLow(:,comparisonWindow),2))
title(['p = ' num2str(p) ', n = ' num2str(length(cells))])



%% seperation to tails

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
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


%% Significance in time
clear 
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis')

WINDOW_SIZE = 50;
NUM_COMPARISONS = 1; 

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 80;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0; % ms in each side
raster_params.SD = 15;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -(raster_params.time_before - ceil(WINDOW_SIZE/2)): ...
    (raster_params.time_after- ceil(WINDOW_SIZE/2));


for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    ind = find(~boolFail);
    
    raster = getRaster(data,ind,raster_params);
    
    func = @(raster) sigFunc(raster,match_p(ind));
    returnTrace(ii,:) = ...
        runningWindowFunction(raster,func,WINDOW_SIZE,NUM_COMPARISONS);

end

figure;
plot(ts,mean(returnTrace))
xlabel('Time from cue')
ylabel('Frac significiant')


sgtitle(req_params.cell_type)


%% Etta squared as function of time

clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
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
        tot_mean = mean([spksHigh, spksLow]);
        ssb = length(spksHigh)*((mean(spksHigh) - tot_mean)^2) + ...
            length(spksLow)*((mean(spksLow) - tot_mean)^2);
        sst = sum(([spksHigh, spksLow]-tot_mean).^2);
        etta(ii,t) = ssb/sst;
    end
end

aveEtta = nanmean(etta);
semEtta = nanstd(etta)/length(cells); 
figure;
errorbar(ts,aveEtta,semEtta); 
xlabel('Time from cue')
ylabel('Etta')


%%
function h = sigFunc(raster,match_p)

% comparison 25 vs 75
spk1 = sum(raster(:,match_p==25));
spk2 = sum(raster(:,match_p==75));
p = ranksum(spk1,spk2);

h = p'<0.05;

end

