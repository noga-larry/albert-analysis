clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
%req_params.ID = setdiff(4000:5000,[4243,4269,4575,4692,4718,4722])
req_params.num_trials = 20;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
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
end

aveLowR = mean(psthLowR);
semLowR = std(psthLowR)/sqrt(length(cells));
aveHighR = mean(psthHighR);
semHighR = std(psthHighR)/sqrt(length(cells));

aveLowNR = mean(psthLowNR);
semLowNR = std(psthLowNR)/sqrt(length(cells));
aveHighNR = mean(psthHighNR);
semHighNR = std(psthHighNR)/sqrt(length(cells));

figure;
subplot(2,1,1);
errorbar(ts,aveLowR,semLowR,'r'); hold on
errorbar(ts,aveHighR,semLowR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('Reward')

subplot(2,1,2);
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveHighNR,semLowNR,'b'); hold on
xlabel('Time for reward')
ylabel('rate (spk/s)')
legend('25','75')
title('No Reward')

figure;
subplot(2,1,1);
scatter(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2));
refline(1,0)
xlabel('75');ylabel('25')
title('Reward')
signrank(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2))



subplot(2,1,2);
scatter(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2))
refline(1,0)
xlabel('75');ylabel('25')
title('No Reward')
signrank(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2))


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

%% Check if reduction inCSK rate is significant
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'reward';
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
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    ind = find ((~match_o) & (~boolFail));

    raster = getRaster(data,ind,raster_params);

    rateCue(ii) = mean(mean(raster(compsrison_window1,:)))*1000;
    rateBaseline(ii) = mean(mean(raster(compsrison_window2,:)))*1000;
end

%%

figure;
scatter(rateBaseline,rateCue);
refline(1,0)
ylabel('Basline')
xlabel('Cue')
p = signrank(rateBaseline,rateCue);
title(num2str(p));




