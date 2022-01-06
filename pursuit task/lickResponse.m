%% Single cell PSTHs

clear;clc

[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = [25:75];


req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 5000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

raster_params.align_to = 'reward';
raster_params.time_before = 300;
raster_params.time_after = 1000;
raster_params.smoothing_margins = 100; % ms in each side
raster_params.SD = 15;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);
ts = -raster_params.time_before:raster_params.time_after;

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolLick = isTrialWithLick(data,raster_params.align_to, 0, 500);
    [~,match_p] = getProbabilities(data);
    [match_o] = getOutcome(data);
    
    ind = find(~boolFail);
    frac = mean(~boolLick(ind));
    
    if frac<0.2 | frac>0.8
        continue
    end
    
    % lick figure - in the 75NR condition
    ind = find(~boolFail & match_p==75 & ~match_o & boolLick);
    raster = getRaster(data,ind,raster_params);
    psth1 = raster2psth(raster,raster_params);
    subplot(2,3,1)
    plotRaster(raster,raster_params)
    subplot(2,3,2)
    ind = find(~boolFail & match_p==75 & ~match_o & ~boolLick);
    raster = getRaster(data,ind,raster_params);
    psth2 = raster2psth(raster,raster_params);
    plotRaster(raster,raster_params)
    ax1 = subplot(2,3,3); hold on
    plot(ts,psth1)
    plot(ts,psth2)
    legend('lick','no lick')
    
    % R/NR
    ind = find(~boolFail & match_o);
    raster = getRaster(data,ind,raster_params);
    psth1 = raster2psth(raster,raster_params);
    subplot(2,3,4)
    plotRaster(raster,raster_params)
    subplot(2,3,5)
    ind = find(~boolFail  & ~match_o );
    raster = getRaster(data,ind,raster_params);
    psth2 = raster2psth(raster,raster_params);
    plotRaster(raster,raster_params)
    ax2 = subplot(2,3,6); hold on
    plot(ts,psth1)
    plot(ts,psth2)
    legend('R','NR')
    
    pause
    
    cla(ax1); cla(ax2)
end


%% Frac significant

clear;clc

[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = [25:75];
WINDOW_SIZE = 50;
NUM_COMPARISONS = 2; 

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 5000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

raster_params.align_to = 'cue';
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0; % ms in each side
raster_params.SD = 15;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);

counter = 0;
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolLick = isTrialWithLick(data,raster_params.align_to, 0, 400);
    [~,match_p] = getProbabilities (data);
    
    ind = find(~boolFail);
    frac = mean(~boolLick(ind));
    
    if frac<0.2 | frac>0.8
        continue
    end
    
    counter = counter+1;
    
    raster = getRaster(data,ind,raster_params);
    
    func = @(raster) sigFunc(raster,boolLick(ind),match_p(ind));
    returnTrace(counter,:,:) = ...
        runningWindowFunction(raster,func,WINDOW_SIZE,NUM_COMPARISONS);
    
end
%%
figure;
ts = -(raster_params.time_before - ceil(WINDOW_SIZE/2)): ...
    (raster_params.time_after- ceil(WINDOW_SIZE/2));

plot(ts,squeeze(mean(returnTrace)))
xlabel('Time from cue')
ylabel('Frac significiant')
legend('Lick vs No Lick', '75 vs 25')

%% Triggered response

clear;clc

[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

SD = 15;
epoch = 'cue';
runningWindow = -300:500;

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;

raster_params.align_to = epoch;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0; % ms in each side

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);

counter = 0;
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    
    [psth,counterOnset(ii)] = lickTriggeredPsth(data,runningWindow,'onset',...
        SD,'epoch',epoch);
    psthOnset(ii,:) = psth-mean(psth);
    
    [psth,counterOffset(ii)] = lickTriggeredPsth(data,runningWindow,...
        'offset',SD,'epoch',epoch);
    psthOffset(ii,:) = psth-mean(psth);
    
    % Simulate R and NR
    
    match_o = getOutcome(data);
    boolFail = [data.trials.fail];
    
    ind = find(~boolFail & match_o);
    
    simulatedPSTHOnset(1,ii,:) = lickSimulation...
         (data,psthOnset(ii,:),runningWindow,'onset',raster_params,ind);
     
    simulatedPSTHOffset(1,ii,:) = lickSimulation...
         (data,psthOffset(ii,:),runningWindow,'offset',raster_params,ind);
     
     ind = find(~boolFail & ~match_o);
    
    simulatedPSTHOnset(2,ii,:) = lickSimulation...
         (data,psthOnset(ii,:),runningWindow,'onset',raster_params,ind);
     
    simulatedPSTHOffset(2,ii,:) = lickSimulation...
         (data,psthOffset(ii,:),runningWindow,'offset',raster_params,ind);
     
end

%%
figure
subplot(2,1,1); hold on
ave = nanmean(psthOnset);
sem = nanSEM(psthOnset);
errorbar(runningWindow,ave,sem)
ave = nanmean(psthOffset);
sem = nanSEM(psthOffset);
errorbar(runningWindow,ave,sem);
xlabel('Time from lick')
ylabel('FR (Hz)')
legend('onset','offset')

subplot(2,2,3)
plot(runningWindow,psthOnset')
xlabel('Time from lick')
ylabel('FR (Hz)')
title('onset')

subplot(2,2,4)
plot(runningWindow,psthOffset')
xlabel('Time from lick')
ylabel('FR (Hz)')
title('offset')
sgtitle(req_params.cell_type)

%%
function h = sigFunc(raster,boolLick,match_p)

spk1 = sum(raster(:,find(boolLick)));
spk2 = sum(raster(:,find(~boolLick)));
p(1) = ranksum(spk1,spk2);

spk1 = sum(raster(:,match_p==25));
spk2 = sum(raster(:,match_p==75));
p(2) = ranksum(spk1,spk2);

h = p<0.05;
end




