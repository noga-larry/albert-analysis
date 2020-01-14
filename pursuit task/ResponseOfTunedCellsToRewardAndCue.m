clear all;
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.time_before = 300;
raster_params.time_after = 1700;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparisonWindow = raster_params.time_before + [400:600];
ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h = nan(length(cells),1);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    indBaseline = find(~boolFail);
    
    rasterBaseline = getRaster(data,indBaseline,raster_params);
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    baseline = mean(raster2psth(rasterBaseline,raster_params));
    psthLow(ii,:) = raster2psth(rasterLow,raster_params)-baseline;
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params)-baseline;
    h(ii) = data.info.directionally_tuned;
    
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
diffTuned = mean(psthHigh(ind,comparisonWindow),2)-mean(psthLow(ind,comparisonWindow),2)
ind = find(~h);
scatter (mean(psthHigh(ind,comparisonWindow),2),mean(psthLow(ind,comparisonWindow),2)); hold on
diffUnTuned = mean(psthHigh(ind,comparisonWindow),2)-mean(psthLow(ind,comparisonWindow),2)
refline (1,0)
p = ranksum(diffTuned,diffUnTuned);
title([' p = ' num2str(p)])


%%

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks =1;
compsrison_window = raster_params.time_before + (100:300);

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indLowNR = find (match_p == 25 & (~match_o) & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    indHighNR = find (match_p == 75 & (~match_o) & (~boolFail));
    
    rasterLowR = getRaster(data,indLowR,raster_params);
    rasterLowNR = getRaster(data,indLowNR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    rasterHighNR = getRaster(data,indHighNR,raster_params);
    
    basline = getRaster(data,find(~boolFail),raster_params);
    baseline = mean(raster2psth(basline,raster_params));
    
    psthLowR(ii,:) = raster2psth(rasterLowR,raster_params) - baseline;
    psthLowNR(ii,:) = raster2psth(rasterLowNR,raster_params) - baseline;
    psthHighR(ii,:) = raster2psth(rasterHighR,raster_params) - baseline;
    psthHighNR(ii,:) = raster2psth(rasterHighNR,raster_params) - baseline;
    
    h(ii) = data.info.directionally_tuned;
end



figure;

ind = find(h);
aveLowR = mean(psthLowR(ind,:));
semLowR = std(psthLowR(ind,:))/sqrt(length(ind));
aveHighR = mean(psthHighR(ind,:));
semHighR = std(psthHighR(ind,:))/sqrt(length(ind));

aveLowNR = mean(psthLowNR(ind,:));
semLowNR = std(psthLowNR(ind,:))/sqrt(length(ind));
aveHighNR = mean(psthHighNR(ind,:));
semHighNR = std(psthHighNR(ind,:))/sqrt(length(ind));

subplot(2,2,1);
errorbar(ts,aveLowR,semLowR,'r'); hold on
errorbar(ts,aveHighR,semHighR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('Reward, tuned')

subplot(2,2,2);
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveHighNR,semHighNR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('No Reward, tuned')


ind = find(~h);
aveLowR = mean(psthLowR(ind,:));
semLowR = std(psthLowR(ind,:))/sqrt(length(ind));
aveHighR = mean(psthHighR(ind,:));
semHighR = std(psthHighR(ind,:))/sqrt(length(ind));

aveLowNR = mean(psthLowNR(ind,:));
semLowNR = std(psthLowNR(ind,:))/sqrt(length(ind));
aveHighNR = mean(psthHighNR(ind,:));
semHighNR = std(psthHighNR(ind,:))/sqrt(length(ind));

subplot(2,2,3);
errorbar(ts,aveLowR,semLowR,'r'); hold on
errorbar(ts,aveHighR,semHighR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('Reward, untuned')

subplot(2,2,4);
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveHighNR,semHighNR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('No Reward, untuned')

figure;
ind = find(h);
subplot(2,1,1);
scatter(mean(psthHighR(ind,compsrison_window),2),...
    mean(psthLowR(ind,compsrison_window),2),'b'); hold on
ind = find(~h);
scatter(mean(psthHighR(ind,compsrison_window),2),...
    mean(psthLowR(ind,compsrison_window),2),'k');
refline(1,0)
xlabel('75');ylabel('25')
title('Reward')
legend('tuned','untuned')

subplot(2,1,2);
ind = find(h);
scatter(mean(psthHighNR(ind,compsrison_window),2),...
    mean(psthLowNR(ind,compsrison_window),2),'b'); hold on
ind = find(~h);
scatter(mean(psthHighNR(ind,compsrison_window),2)...
    ,mean(psthLowNR(ind,compsrison_window),2),'k')
refline(1,0)
xlabel('75');ylabel('25')
title('No Reward')
legend('tuned','untuned')


%% 
clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'reward';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 50; % ms in each side

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before : raster_params.time_after;


HighTail = nan(length(cells),length(ts));
LowTail = nan(length(cells),length(ts));

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indR = find ( match_o & (~boolFail));
    indNR = find ((~match_o) & (~boolFail));
    indSuprise = find (((match_p == 75 & (~match_o))| ...
        (match_p == 25 & match_o) ) & (~boolFail));
    indNoSuprise = find (((match_p == 25 & (~match_o))| ...
        (match_p == 75 & match_o) ) & (~boolFail));
    
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    rasterSuprise = getRaster(data,indSuprise,raster_params);
    rasterNoSuprise = getRaster(data,indNoSuprise,raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spksR = sum(rasterR(runningWindow,:));
        spksNR = sum(rasterNR(runningWindow,:));
        spksSuprise = sum(rasterSuprise(runningWindow,:));
        spksNoSuprise = sum(rasterNoSuprise(runningWindow,:));
        [~,R(ii,t)] = ranksum(spksR,spksNR,'tail','right');
        [~,NR(ii,t)] = ranksum(spksR,spksNR,'tail','left');
        [~,NoSuprise(ii,t)] = ranksum(spksNoSuprise,spksSuprise,'tail','right');
        [~,Suprise(ii,t)] = ranksum(spksNoSuprise,spksSuprise,'tail','left');
    end
    
        h(ii) = data.info.directionally_tuned;

end

%%




figure;
subplot(2,1,1)

ind = find(h);
fracNR = mean(NR(ind,:)>0.05);
fracR = mean(R(ind,:)>0.05);
plot(ts,fracR,'m'); hold on
plot(ts,fracNR,'k')

ind = find(~h);
fracNR = mean(NR(ind,:)>0.05);
fracR = mean(R(ind,:)>0.05);
plot(ts,fracR,'m--'); hold on
plot(ts,fracNR,'k--')

title ('Reward vs No Reward')
xlabel('Time from reward')
ylabel('Frac of cells')
legend ('R, tuned','NR, tuned','R, untuned','NR, untuned')

subplot(2,1,2)
ind = find(h);
fracNoSuprise = mean(NoSuprise(ind,:)>0.05);
fracSuprise = mean(Suprise(ind,:)>0.05);
plot(ts,fracSuprise,'m'); hold on
plot(ts,fracNoSuprise,'k')

ind = find(~h);
fracNoSuprise = mean(NoSuprise(ind,:)>0.05);
fracSuprise = mean(Suprise(ind,:)>0.05);
plot(ts,fracSuprise,'--m'); hold on
plot(ts,fracNoSuprise,'--k')


title ('Suprise vs No Suprise')
xlabel('Time from reward')
ylabel('Frac of cells')
legend ('Suprise, tuned','No Suprise, tuned')
legend ('Suprise, untuned','No Suprise, untuned')


