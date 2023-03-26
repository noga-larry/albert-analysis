
%% Make list of significant cells
clear; clc
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");

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

req_params = reqParamsEffectSize("both");
%req_params.cell_type = {'PC cs'};

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

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

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;


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

%%

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));

    aveLowR = nanmean(psthLowR(indType,:));
    semLowR =  nanSEM(psthLowR(indType,:));
    aveHighR = nanmean(psthHighR(indType,:));
    semHighR = nanSEM(psthHighR(indType,:));

    aveLowNR = nanmean(psthLowNR(indType,:));
    semLowNR = nanSEM(psthLowNR(indType,:));
    aveHighNR = nanmean(psthHighNR(indType,:));
    semHighNR = nanSEM(psthHighNR(indType,:));


    figure;
    subplot(2,2,1);
    errorbar(ts,aveLowR,semLowR,'r'); hold on
    errorbar(ts,aveHighR,semHighR,'b'); hold on
    xlabel('Time for reward')
    ylabel('rate (spk/s)')
    legend('25','75')
    title('Reward')

    subplot(2,2,3);
    errorbar(ts,aveLowNR,semLowNR,'r'); hold on
    errorbar(ts,aveHighNR,semHighNR,'b'); hold on
    xlabel('Time for reward')
    ylabel('rate (spk/s)')
    legend('25','75')
    title('No Reward')

    subplot(3,2,2);
    scatter(mean(psthHighR(indType,compsrison_window),2),mean(psthLowR(indType,compsrison_window),2)); hold on
    %scatter(mean(psthHighR(find(h),compsrison_window),2),mean(psthLowR(find(h),compsrison_window),2));
    refline(1,0)
    xlabel('75');ylabel('25')
    title('Reward')
    p = signrank(mean(psthHighR(indType,compsrison_window),2),mean(psthLowR(indType,compsrison_window),2))
    title(['Reward: p=' num2str(p) ', n=' num2str(length(cells))])

    subplot(3,2,4);
    scatter(mean(psthHighNR(indType,compsrison_window),2),mean(psthLowNR(indType,compsrison_window),2)); hold on
    %scatter(mean(psthHighNR(find(h),compsrison_window),2),mean(psthLowNR(find(h),compsrison_window),2))
    refline(1,0)
    xlabel('75');ylabel('25')
    p = signrank(mean(psthHighNR(indType,compsrison_window),2),mean(psthLowNR(indType,compsrison_window),2))
    title(['No Reward: p=' num2str(p) ', n=' num2str(length(cells))])

    subplot(3,2,6);
    scatter(mean(psthHighNR(indType,compsrison_window),2),mean(psthLowR(indType,compsrison_window),2)); hold on
    refline(1,0)
    xlabel('75 - NR');ylabel('25 - R')
    [r,p] = corr(mean(psthHighNR(indType,compsrison_window),2),...
        mean(psthLowR(indType,compsrison_window),2),'type','Spearman');
    title([' correlation: r =  ' num2str(r) ...
        ', p=' num2str(p) ', n=' num2str(length(indType))])
    p = signrank(mean(psthHighNR(indType,compsrison_window),2),mean(psthLowR(indType,compsrison_window),2)); hold on

    subtitle(['Signrank:' num2str(p)])

    sgtitle([req_params.cell_type{i} 'n = ' num2str(length(indType))])


end
%% High rate vs low rate
clear; clc
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis');
OUTCOMES = [0 1];
req_params = reqParamsEffectSize("both");
%req_params.cell_type = {'PC cs'};

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);


cells = findPathsToCells (supPath,task_info,lines);

psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));

for ii = 1:length(cells)

    data = importdata(cells{ii});
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    baseline = mean(getPSTH(data,find(~boolFail),raster_params),1);
    if  strcmp(req_params.cell_type,'PC cs')
        baseline = 0;
    end

    for j=1:length(OUTCOMES)
        ind = find (match_o == OUTCOMES(j) & (~boolFail));
        psths{j} = getPSTH(data,ind,raster_params) - baseline;
        rate(j) = mean(psths{j},1);
    end

    
    if rate(1)>rate(2)
        psthHigh(ii,:) = psths{1};
        psthLow(ii,:) = psths{2};
    else
        psthHigh(ii,:) = psths{2};
        psthLow(ii,:) = psths{1};
    end
end

%%
figure;


for i = 1:length(req_params.cell_type)
        
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    subplot(length(req_params.cell_type),1,i); hold on

    ave = mean(psthLow(indType,:));
    sem = nanSEM(psthLow(indType,:));
    errorbar(ts,ave,sem,'r');

    ave = mean(psthHigh(indType,:));
    sem = nanSEM(psthHigh(indType,:));
    errorbar(ts,ave,sem,'b');

    xlabel('Time from cue (ms)')
    ylabel('\Delta Rate')
    title([req_params.cell_type{i} ', n = ' num2str(length(indType))])
    legend('Low','High')

end



