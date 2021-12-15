
%% Make list of significant cells
clear; clc
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;
req_params.grade = 7;
req_params.cell_type = 'SNR';
req_params.num_trials = 50;
req_params.remove_repeats = 0;
req_params.ID = 4000:6000;

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

save (task_DB_path,'task_info')

%% PSTHs
clear; clc
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;
req_params.grade = 7;
req_params.cell_type = 'SNR';
req_params.num_trials = 50;
req_params.remove_repeats = 0;
req_params.ID = 4000:5000;

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

compsrison_window = raster_params.time_before + (100:500);

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);

% lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
% lickInd = [lickInd{:}];
% lickInd = find(lickInd);
% lines = lines(lickInd);

% lines = lines(~[task_info(lines).directionally_tuned]);
cells = findPathsToCells (supPath,task_info,lines);

psthLowR = nan(length(cells),length(ts));
psthLowNR = nan(length(cells),length(ts));

psthHighR = nan(length(cells),length(ts));
psthHighNR = nan(length(cells),length(ts));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    % h(ii) = task_info(lines(ii)).cue_differentiating;
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
    
    baseline = mean(getPSTH(data,find(~boolFail),raster_params));
    
    if strcmp(req_params.cell_type,'PC cs')
        baseline = 0;
    end
    
   
    psthLowR(ii,:) = raster2psth(rasterLowR,raster_params) - baseline;
    psthLowNR(ii,:) = raster2psth(rasterLowNR,raster_params) - baseline;
    psthHighR(ii,:) = raster2psth(rasterHighR,raster_params) - baseline;
    psthHighNR(ii,:) = raster2psth(rasterHighNR,raster_params) - baseline;
    
end

aveLowR = nanmean(psthLowR);
semLowR =  nanSEM(psthLowR);
aveHighR = nanmean(psthHighR);
semHighR = nanSEM(psthHighR);

aveLowNR = nanmean(psthLowNR);
semLowNR = nanSEM(psthLowNR);
aveHighNR = nanmean(psthHighNR);
semHighNR = nanSEM(psthHighNR);


f = figure; f.Position = [10 80 700 500];
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

f = figure; f.Position = [10 80 700 500];
subplot(2,1,1);
scatter(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2)); hold on
%scatter(mean(psthHighR(find(h),compsrison_window),2),mean(psthLowR(find(h),compsrison_window),2));
refline(1,0)
xlabel('75');ylabel('25')
title('Reward')
p = signrank(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2))
title(['Reward: p=' num2str(p) ', n=' num2str(length(cells))])

subplot(2,1,2);
scatter(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2)); hold on
%scatter(mean(psthHighNR(find(h),compsrison_window),2),mean(psthLowNR(find(h),compsrison_window),2))
refline(1,0)
xlabel('75');ylabel('25')
p = signrank(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2))
title(['No Reward: p=' num2str(p) ', n=' num2str(length(cells))])


figure;
scatter(mean(psthHighNR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2)); hold on
refline(1,0)
xlabel('75 - NR');ylabel('25 - R')
[r,p] = corr(mean(psthHighNR(:,compsrison_window),2),...
    mean(psthLowR(:,compsrison_window),2),'type','Spearman');
title([req_params.cell_type ' correlation: r =  ' num2str(r) ...
    ', p=' num2str(p) ', n=' num2str(length(cells))])
p = signrank(mean(psthHighNR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2)); hold on

subtitle(['Signrank:' num2str(p)])


%% Significance in time
clear 
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis')

WINDOW_SIZE = 50;
NUM_COMPARISONS = 7; 
PLOT_INDIVIDUAL = false;

req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 80;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
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
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    ind = find(~boolFail);
    
    raster = getRaster(data,ind,raster_params);
    
    func = @(raster) sigFunc(raster,match_p(ind),match_o(ind));
    returnTrace(ii,:,:) = ...
        runningWindowFunction(raster,func,WINDOW_SIZE,NUM_COMPARISONS);

    if PLOT_INDIVIDUAL
       ax1 = subplot(2,1,1); hold on
        
       ind = find (match_p==75 & match_o);
       psth = getSTpsth(data,ind,raster_params);
       ave = nanmean(psth); sem = nanSEM(psth);
       errorbar(-raster_params.time_before:...
           raster_params.time_after,ave,sem,'b')
       
       ind = find (match_p==75 & ~match_o);
       psth = getSTpsth(data,ind,raster_params);
       ave = nanmean(psth); sem = nanSEM(psth);
       errorbar(-raster_params.time_before:...
           raster_params.time_after,ave,sem,'--b')
       marks = ts(find(returnTrace(ii,:,5)));
       plot(marks,ones(length(marks),1),'k*')
       title('75')       
       
       ax2 = subplot(2,1,2); hold on
        
       ind = find (match_p==25 & match_o);
       psth = getSTpsth(data,ind,raster_params);
       ave = nanmean(psth); sem = nanSEM(psth);
       errorbar(-raster_params.time_before:...
           raster_params.time_after,ave,sem,'r')
       
       ind = find (match_p==25 & ~match_o);
       psth = getSTpsth(data,ind,raster_params);
       ave = nanmean(psth); sem = nanSEM(psth);
       errorbar(-raster_params.time_before:...
           raster_params.time_after,ave,sem,'--r')
       title('25')
       marks = ts(find(returnTrace(ii,:,4)));
       plot(marks,ones(length(marks),1),'k*')
       
       pause
       cla(ax1); cla(ax2)
    end
end

%%
figure;
subplot(3,1,1)
plot(ts,squeeze(mean(returnTrace(:,:,1:3))))
xlabel(['Time from ' raster_params.align_to])
ylabel('Frac significiant')
legend('R vs NR', '75 vs 25','Unlikely vs likely result')

subplot(3,1,2); hold on
plot(ts,squeeze(mean(returnTrace(:,:,5))),'b')
plot(ts,squeeze(mean(returnTrace(:,:,4))),'r')
xlabel(['Time from ' raster_params.align_to])
ylabel('Frac significiant')
legend('R vs NR in 25', 'R vs NR in 75')

subplot(3,1,3); hold on
plot(ts,squeeze(mean(returnTrace(:,:,6))),'b')
plot(ts,squeeze(mean(returnTrace(:,:,7))),'r')
xlabel(['Time from ' raster_params.align_to])
ylabel('Frac significiant')
legend('25 vs 75 in R', '25 vs 75 in NR')


sgtitle(req_params.cell_type)
%%
function h = sigFunc(raster,match_p,match_o)
% comparison R vs NR
spk1 = sum(raster(:,match_o));
spk2 = sum(raster(:,~match_o));
p(1) = ranksum(spk1,spk2);

% comparison 25 vs 75
spk1 = sum(raster(:,match_p==25));
spk2 = sum(raster(:,match_p==75));
p(2) = ranksum(spk1,spk2);

% comparison suprise 
spk1 = sum(raster(:,(match_p==25 & match_o) | ...
    match_p==75 & ~match_o));
spk2 = sum(raster(:,(match_p==25 & ~match_o) | ...
    match_p==75 & match_o));
p(3) = ranksum(spk1,spk2);

% within 25 
spk1 = sum(raster(:,match_p==25 & match_o));
spk2 = sum(raster(:,match_p==25 & ~match_o));
p(4) = ranksum(spk1,spk2);

% within 75

spk1 = sum(raster(:,match_p==75 & match_o));
spk2 = sum(raster(:,match_p==75 & ~match_o));
p(5) = ranksum(spk1,spk2);

% within R

spk1 = sum(raster(:,match_p==75 & match_o));
spk2 = sum(raster(:,match_p==25 & match_o));
p(6) = ranksum(spk1,spk2);

% within NR

spk1 = sum(raster(:,match_p==75 & ~match_o));
spk2 = sum(raster(:,match_p==25 & ~match_o));
p(7) = ranksum(spk1,spk2);



h = p'<0.05;

end

