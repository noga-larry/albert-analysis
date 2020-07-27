
%% Make list of significant cells
clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;
req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.num_trials = 20;
req_params.remove_repeats = 0;


raster_params.align_to = 'reward';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells )
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    match_o = getOutcome (data);
    boolFail = [data.trials.fail];
    
    group = match_p*10+match_o; 
    group = group(~boolFail);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    spikes = sum(raster,1);
    
    p = kruskalwallis(spikes,group,'off');
    
    task_info(lines(ii)).outcome_differentiating = p<0.05;
    
    
    
end

save ('C:\Users\Noga\Documents\Vermis Data\task_info','task_info');

%% PSTHs
clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');


req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
%req_params.ID = setdiff(4000:5000,[4243,4269,4575,4692,4718,4722])
%cells from saccade task:
% req_params.ID = [4127,4237,4238,4239,4243,4262,4269,4274,4275,4276,4282,4328,4347,4369,4457,4535,4536,4569,4570,4578,4582,4602,4609,4610,4618,4619,4685,4695,4707,4721,4737,4785,4810,4839,4854,4857,4907,4917,4937,4968,4970,4987,4988]
req_params.num_trials = 40;
req_params.remove_question_marks = 1;


raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

compsrison_window = raster_params.time_before + (100:300);

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
lines = lines(~[task_info(lines).directionally_tuned]);
cells = findPathsToCells (supPath,task_info,lines);

psthLowR = nan(length(cells),length(ts));
psthLowNR = nan(length(cells),length(ts));

psthHighR = nan(length(cells),length(ts));
psthHighNR = nan(length(cells),length(ts));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    h(ii) = task_info(lines(ii)).cue_differentiating;
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
    
    if ~strcmp(req_params.cell_type,'PC cs')
        rasterBaseline = getRaster(data,indBaseline,raster_params);
        baseline = mean(raster2psth(rasterBaseline,raster_params));
    else
        baseline = 0;
    end
    
   
    psthLowR(ii,:) = raster2psth(rasterLowR,raster_params) - baseline;
    psthLowNR(ii,:) = raster2psth(rasterLowNR,raster_params) - baseline;
    psthHighR(ii,:) = raster2psth(rasterHighR,raster_params) - baseline;
    psthHighNR(ii,:) = raster2psth(rasterHighNR,raster_params) - baseline;
    
end

aveLowR = nanmean(psthLowR);
semLowR =  nanstd(psthLowR)/sqrt(length(cells));
aveHighR = nanmean(psthHighR);
semHighR = nanstd(psthHighR)/sqrt(length(cells));

aveLowNR = nanmean(psthLowNR);
semLowNR = nanstd(psthLowNR)/sqrt(length(cells));
aveHighNR = nanmean(psthHighNR);
semHighNR = nanstd(psthHighNR)/sqrt(length(cells));

figure;
subplot(2,1,1);
errorbar(ts,aveLowR,semLowR,'r'); hold on
errorbar(ts,aveHighR,semHighR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('Reward')

subplot(2,1,2);
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveHighNR,semHighNR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('No Reward')

figure;
subplot(2,1,1);
scatter(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2)); hold on
scatter(mean(psthHighR(find(h),compsrison_window),2),mean(psthLowR(find(h),compsrison_window),2));
refline(1,0)
xlabel('75');ylabel('25')
title('Reward')
p = signrank(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2))
title(['Reward: p=' num2str(p) ', n=' num2str(length(cells))])



subplot(2,1,2);
scatter(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2)); hold on
scatter(mean(psthHighNR(find(h),compsrison_window),2),mean(psthLowNR(find(h),compsrison_window),2))

refline(1,0)
xlabel('75');ylabel('25')
p = signrank(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2))
title(['No Reward: p=' num2str(p) ', n=' num2str(length(cells))])

%




%%
clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'CRB';
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
LowTail =nan(length(cells),length(ts));

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
end


%%
fracNR = mean(NR>0.05);
fracR = mean(R>0.05);
fracNoSuprise = mean(NoSuprise>0.05);
fracSuprise = mean(Suprise>0.05);
figure;
subplot(2,1,1)
plot(ts,fracR,'m'); hold on
plot(ts,fracNR,'k')
title ('Reward vs No Reward')
xlabel('Time from reward')
ylabel('Frac of cells')
legend ('R','NR')

subplot(2,1,2)
plot(ts,fracSuprise,'m'); hold on
plot(ts,fracNoSuprise,'k')
title ('Suprise vs No Suprise')
xlabel('Time from reward')
ylabel('Frac of cells')
legend ('Suprise','No Suprise')


%%
clear all
prob = 75;

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
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
LowTail =nan(length(cells),length(ts));

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indR = find (match_p == prob & match_o & (~boolFail));
    indNR = find (match_p == prob &(~match_o) & (~boolFail));
   
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spksR = sum(rasterR(runningWindow,:));
        spksNR = sum(rasterNR(runningWindow,:));

        [~,R(ii,t)] = ranksum(spksR,spksNR,'tail','right');
        [~,NR(ii,t)] = ranksum(spksR,spksNR,'tail','left');
     end
end



fracNR = mean(NR>0.05);
fracR = mean(R>0.05);

figure;
plot(ts,fracR,'m'); hold on
plot(ts,fracNR,'k')
title ('Reward vs No Reward')
xlabel('Time from reward')
ylabel('Frac of cells')
legend ('R','NR')

title(num2str(prob))

%% Check if reduction in Cspk rate is significant
clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 40;
req_params.remove_question_marks = 1;


raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
raster_params.SD = 10;
req_params.remove_question_marks =1;
compsrison_window1 = raster_params.smoothing_margins + ...
    raster_params.time_before + (100:300);
compsrison_window2 = raster_params.smoothing_margins + ...
    raster_params.time_before - (100:300);

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
lines = lines(~[task_info(lines).directionally_tuned]);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
   
    h(ii) = task_info(lines(ii)).cue_differentiating;

    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    ind = find ((~match_o) & (~boolFail));

    raster = getRaster(data,ind,raster_params);

    rateCue(ii) = mean(mean(raster(compsrison_window1,:)))*1000;
    rateBaseline(ii) = mean(mean(raster(compsrison_window2,:)))*1000;
end



figure;
scatter(rateBaseline,rateCue); hold on
scatter(rateBaseline(find(h)),rateCue(find(h)));
refline(1,0)
xlabel('Basline')
ylabel('reward')
p = signrank(rateBaseline,rateCue);
title(['p=' num2str(p) ', n=' num2str(length(cells))])

%% Check response without saccdes 

