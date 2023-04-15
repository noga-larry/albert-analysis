%% Behavior figure

clear 

[task_info,supPath, MaestroPath,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

behavior_params.time_after = 1500;
behavior_params.time_before = 2000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms
behavior_params.align_to = 'reward';

ts = -behavior_params.time_before:behavior_params.time_after;

cellID = [];
for ii = 1:length(cells)

    data = importdata(cells{ii});
    [data,flagCross] = getLicking(data,MaestroPath);
    
    if (~flagCross) 
        continue
    end
    
    ind = find(~[data.trials.fail]);
    licks = meanLicking(data,behavior_params,ind);
    
    plot(ts,licks)
    title([num2str(data.info.cell_ID) ', ' data.info.session ])
    signalQuality = input('1- good signal,0-bad signal');
    task_info(lines(ii)).lick = signalQuality;
    if signalQuality
        cellID = [cellID data.info.cell_ID];
    end
    
    
end

save(task_DB_path,'task_info');
%%

clear
PROBABILITIES = [25,75];
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms
behavior_params.align_to = 'cue';

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    

    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    match_po = getPreviousOutcomes(data);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1) = 1;
    
    cellID(ii) = data.info.cell_ID;

    
    for p = 1:length(PROBABILITIES)
        for j=1:2
            ind = find (match_p == PROBABILITIES(p) & ...
                (~boolFail) & match_po == j-1 );
            licks(ii,p,j,:) = meanLicking(data,behavior_params,ind);
        end
    end
    
end


%%

aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));
col = {'r','b'}
figure
for j=1:2
    subplot(2,1,j); hold on
    for i=1:length(PROBABILITIES)
        errorbar(ts,squeeze(aveLicks(i,j,:)),squeeze(semLicks(i,j,:)),col{i})
    end
    ylim([0,1])
    title(['Previous outcome: ' num2str(j-1)])
    xlabel(['Time from  ' behavior_params.align_to])
    ylabel('Fraction of trials with lick')
end

%%

h = cellID<5000;
aveLicks = squeeze(mean(licks(h,:,:,:),[1,3]));
semLicks = squeeze(nanSEM(licks(h,:,:,:),[1,3]));
col = {'r','b'};
figure; hold on
for i=1:length(PROBABILITIES)
    errorbar(ts,squeeze(aveLicks(i,:)),squeeze(semLicks(i,:)),col{i})
end
ylim([0,1])
xlabel(['Time from  ' behavior_params.align_to])
ylabel('Fraction of trials with lick')


%% reward epoch
clear
PROBABILITIES = [25,75];
OUTCOMES = [0 1];
PLOT_CELLS = false;
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both","albert");

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms
behavior_params.align_to = 'reward';

ts = -behavior_params.time_before:behavior_params.time_after;

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
    [match_o] = getOutcome(data);
    boolFail = [data.trials.fail];
    
    for p = 1:length(PROBABILITIES)
        for j=1:length(OUTCOMES)
            ind = find (match_p == PROBABILITIES(p)...
                & match_o == OUTCOMES(j) & (~boolFail));
            licks(ii,p,j,:) = meanLicking(data,behavior_params,ind);
        end
    end
    
    if PLOT_CELLS
        subplot(1,2,1)
        plot(ts,licksLowR(ii,:),'r'); hold on
        plot(ts,licksHighR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('Reward')
        
        subplot(1,2,2)
        plot(ts,licksLowNR(ii,:),'r'); hold on
        plot(ts,licksHighNR(ii,:),'b'); hold off
        xlabel('Time from Reward')
        ylabel('Fraction of trials with lick')
        title('No Reward')
        
        
        pause
    end
end
    

aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));

figure
subplot(2,1,1); hold on

errorbar(ts,squeeze(aveLicks(2,1,:)),squeeze(semLicks(2,1,:)),'b') 
errorbar(ts,squeeze(aveLicks(1,1,:)),squeeze(semLicks(1,1,:)),'r') 
xlabel('Time from outcome')
ylabel('Fraction of trials with lick')
ylim([0 1])
title('NR')  
legend({'75' '25'})

subplot(2,1,2); hold on
errorbar(ts,squeeze(aveLicks(1,2,:)),squeeze(semLicks(1,2,:)),'r')
errorbar(ts,squeeze(aveLicks(2,2,:)),squeeze(semLicks(2,2,:)),'b')
 
xlabel('Time from outcome')
ylabel('Fraction of trials with lick')
ylim([0 1])
title('R') 
legend({'25' '75' })

%% lick direcion dependency

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25,75];
DIRECTIONS = 0:45:315;

req_params = reqParamsEffectSize("both");

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms
behavior_params.align_to = 'targetMovementOnset';

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

cells = findPathsToCells (supPath,task_info,lines);
licks = nan(length(cells),length(PROBABILITIES),length(DIRECTIONS), length(ts));
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    match_po = getPreviousOutcomes(data);
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    for p = 1:length(PROBABILITIES)
       for d = 1: length(DIRECTIONS)
            ind = find (match_p == PROBABILITIES(p) & ...
                (~boolFail) & match_d == DIRECTIONS(d));
            licks(ii,p,d,:) = meanLicking(data,behavior_params,ind);
       end
    end
    
end

%%
aveLicks = squeeze(mean(licks));
semLicks = squeeze(nanSEM(licks));

col = {'r','b'};
figure;
for d = 1: length(DIRECTIONS)
    subplot(4,2,d); hold on
    for p = 1:length(PROBABILITIES)
        errorbar(ts,squeeze(aveLicks(p,d,:)),squeeze(semLicks(p,d,:)),col{p})
    end
    title(num2str(DIRECTIONS(d)))
    ylim([0 0.4])
end