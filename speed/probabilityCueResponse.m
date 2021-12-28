% Probability Cue Response
clear; clc; close all
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

% Make list of significant cells


req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC|BG msn|SNR';
req_params.num_trials = 50;

raster_params.align_to = 'cue';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

ts = -raster_params.time_before:raster_params.time_after;
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
h = nan(length(cells),1);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];;
    
    indLow = find (match_p == 0 & (~boolFail));
    indMid = find (match_p == 50 & (~boolFail));
    indHigh = find (match_p == 100 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterMid = getRaster(data,indMid,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    spikesLow = sum(rasterLow,1);
    spikesMid = sum(rasterMid,1);    
    spikesHigh = sum(rasterHigh,1);
    group = cell(1,length(spikesLow)+length(spikesMid)+length(spikesHigh));
    group(1:length(spikesLow)) = {'Low'};
    group(length(spikesLow)+1:length(spikesLow)+length(spikesMid)) = {'Mid'};
    group(length(spikesLow)+length(spikesMid)+1:...
        length(spikesLow)+length(spikesMid)+length(spikesHigh)) = {'High'};
    
    p = kruskalwallis([spikesLow,spikesMid,spikesHigh],group,'off');
    h(ii) = p<0.05;
    task_info(lines(ii)).cue_differentiating = h(ii);
    
    
    
end

save (task_DB_path,'task_info')


%% PSTHs

clear 
[task_info, supPath ,~,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');


req_params.grade = 7;
req_params.cell_type = 'BG msn';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.align_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparisonWindow = raster_params.time_before + [100:300];
ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthMid = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h = nan(length(cells),1);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    indLow = find (match_p == 0 & (~boolFail));
    indMid = find (match_p == 50 & (~boolFail));
    indHigh = find (match_p == 100 & (~boolFail));
    
    
    rasterLow = getRaster(data,indLow,raster_params);
    rasterMid = getRaster(data,indMid,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    baseline = mean(getPSTH(data,find(~boolFail),raster_params));
    
    if strcmp(req_params.cell_type,'PC cs')
        baseline = 0;
    end
    
    
    psthLow(ii,:) = raster2psth(rasterLow,raster_params)-baseline;
    psthMid(ii,:) = raster2psth(rasterMid,raster_params)-baseline;
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params)-baseline;
    h(ii) = task_info(lines(ii)).cue_differentiating;
    
end


f = figure; f.Position = [10 80 700 500];

subplot(3,1,1)
ind = find(h);
aveLow = mean(psthLow(ind,:));
semLow = nanSEM(psthLow(ind,:));
aveMid = mean(psthMid(ind,:));
semMid = nanSEM(psthMid(ind,:));
aveHigh = mean(psthHigh(ind,:));
semHigh = nanSEM(psthHigh(ind,:));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveMid,semMid,'k'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Significant, n = ' num2str(length(ind))])

subplot(3,1,2)
ind = find(~h);
aveLow = mean(psthLow(ind,:));
semLow = nanSEM(psthLow(ind,:));
semMid = nanSEM(psthLow(ind,:));
aveMid = mean(psthMid(ind,:));
aveHigh = mean(psthHigh(ind,:));
semHigh = nanSEM(psthHigh(ind,:));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveMid,semMid,'k'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Not Significant, n = ' num2str(length(ind))])

subplot(3,1,3)
aveLow = mean(psthLow);
semLow = nanSEM(psthLow);
semMid = nanSEM(psthLow);
aveMid = mean(psthMid);
aveHigh = mean(psthHigh);
semHigh = nanSEM(psthHigh);
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveMid,semMid,'k'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
legend('0','50','100')
xlabel('Time from cue (ms)')
title (['All, n = ' num2str(length(cells))])

f = figure; f.Position = [10 80 700 500];
subplot(2,1,1)
ind = find(h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
ind = find(~h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
refline (1,0)
p = signrank(mean(psthHigh(:,comparisonWindow),2),mean(psthLow(:,comparisonWindow),2)); hold on
title(['p = ' num2str(p) 'n = ' num2str(length(cells))])
xlabel('100');ylabel('0')

subplot(2,1,2)
ind = find(h);
aveHighMid = 0.5*(psthHigh+psthMid);
scatter (mean(aveHighMid(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
ind = find(~h);
scatter (mean(aveHighMid(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
refline (1,0)
p = signrank(mean(aveHighMid(:,comparisonWindow),2),mean(psthLow(:,comparisonWindow),2)); hold on
title(['p = ' num2str(p) 'n = ' num2str(length(cells))])
xlabel('(100+50)/2');ylabel('0')

f = figure; f.Position = [10 80 700 500];
distHighMid = mean(sqrt((psthHigh-psthMid).^2),2);  
distLowMid = mean(sqrt((psthLow-psthMid).^2),2); 
scatter(distHighMid,distLowMid)
p = signrank(distHighMid,distLowMid)
xlabel('PSTH distance 100 to 50');
ylabel('PSTH distance 0 to 50');
equalAxis(); refline (1,0);
title(['signrank: p = ' num2str(p) ', n = ' num2str(length(cells))])
%% seperation to tails

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
cells = findPathsToCells (supPath,task_info,req_params);
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


