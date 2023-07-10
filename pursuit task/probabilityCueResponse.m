%% PSTHs

clear
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
req_params.cell_type = {'PC cs'};

raster_params.align_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

if ~strcmp(req_params.cell_type,'PC cs')
    comparisonWindow = raster_params.time_before + [0:800];
else
    comparisonWindow = raster_params.time_before + [100:300];
end

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));
h = nan(length(cells),1);
cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});

    [~, ~, ~, ~,pValsOutput] = effectSizeInEpoch(data,raster_params.align_to); 
    h(ii) = pValsOutput.time<0.05; %time

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    [~,match_p] = getProbabilities (data);

    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    indBaseline = find(~boolFail);

    if ~strcmp(req_params.cell_type,'PC cs')
        baseline = mean(raster2psth(getRaster(data,indBaseline,raster_params),raster_params));
    else
        baseline = 0;
    end

    psthLow(ii,:) = getPSTH(data,indLow,raster_params)-baseline;
    psthHigh(ii,:) = getPSTH(data,indHigh,raster_params)-baseline;

    % significance:
%     
%     rasterLow = getRaster(data,indLow,raster_params);
%     spkLow = sum(rasterLow(comparisonWindow,:),1);
%     rasterHigh = getRaster(data,indHigh,raster_params);
%     spkHigh = sum(rasterHigh(comparisonWindow,:),1);
%     [~,h(ii)] = ranksum(spkLow,spkHigh);
end

%%

figure;
for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(length(req_params.cell_type),1,i)
    aveLow = mean(psthLow(indType,:));
    semLow = nanSEM(psthLow(indType,:));
    aveHigh = mean(psthHigh(indType,:));
    semHigh = nanSEM(psthHigh(indType,:));
    errorbar(ts,aveLow,semLow,'r'); hold on
    errorbar(ts,aveHigh,semHigh,'b'); hold on
    xlabel('Time from cue (ms)')
    title ([req_params.cell_type{i} ', n = ' num2str(length(indType))])
legend({'25','75'})
end

%%

subplot(3,1,1)
ind = find(h);
aveLow = mean(psthLow(ind,:));
semLow = nanSEM(psthLow(ind,:));
aveHigh = mean(psthHigh(ind,:));
semHigh = nanSEM(psthHigh(ind,:));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Significant, n = ' num2str(length(ind))])

subplot(3,1,2)
ind = find(~h);
aveLow = mean(psthLow(ind,:));
semLow = nanSEM(psthLow(ind,:));
aveHigh = mean(psthHigh(ind,:));
semHigh = nanSEM(psthHigh(ind,:));
errorbar(ts,aveLow,semLow,'r'); hold on
errorbar(ts,aveHigh,semHigh,'b'); hold on
xlabel('Time from cue (ms)')
title (['Not Significant, n = ' num2str(length(ind))])


subplot(3,1,3)
aveLow = mean(psthLow);
semLow = nanSEM(psthLow);
aveHigh = mean(psthHigh);
semHigh = nanSEM(psthHigh);
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


%%

late_mod_inx = (raster_params.time_before + 300):length(ts)
late_mod_direction = mean(psthHigh(:,late_mod_inx)-psthLow(:,late_mod_inx),2)>0;

figure;
subplot(2,1,1); hold on
errorbar(ts,mean(psthLow(late_mod_direction,:)),nanSEM(psthLow(late_mod_direction,:)),'r')
errorbar(ts,mean(psthHigh(late_mod_direction,:)),nanSEM(psthHigh(late_mod_direction,:)),'b')
xlabel('time for cue'); ylabel('rate (Hz)')

subplot(2,1,2); hold on
errorbar(ts,mean(psthLow(~late_mod_direction,:)),nanSEM(psthLow(~late_mod_direction,:)),'r')
errorbar(ts,mean(psthHigh(~late_mod_direction,:)),nanSEM(psthHigh(~late_mod_direction,:)),'b')
xlabel('time for cue'); ylabel('rate (Hz)')

%% seperation to tails

clear

PROBABILITIES = [25,75];

[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
%req_params.cell_type = {'PC cs'};

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.align_to = 'cue';
raster_params.SD = 20;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

psthLow = nan(length(cells),length(ts));
psthHigh = nan(length(cells),length(ts));

comp_window = raster_params.smoothing_margins+raster_params.time_before

for ii = 1:length(cells)

    data = importdata(cells{ii});

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

    psth_baseline = getPSTH(data,find(~boolFail),raster_params);
    baseline = mean(psth_baseline(raster_params.time_before:end));
    
    if  strcmp(req_params.cell_type,'PC cs')
        baseline = 0;
    end

    for p=1:length(PROBABILITIES)
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        psths{p} = getPSTH(data,ind,raster_params) - baseline;
        raster = getRaster(data,ind,raster_params);
        raster = raster((raster_params.smoothing_margins+raster_params.time_before):...
            (end-raster_params.smoothing_margins),:);
        spks{p} = sum(raster);
        rate(p) = mean(raster,'all')*1000;
        
         
    end

    
    if rate(1)>rate(2)
        psthHigh(ii,:) = psths{1};
        psthLow(ii,:) = psths{2};
    else
        psthHigh(ii,:) = psths{2};
        psthLow(ii,:) = psths{1};
    end
    
    h(ii) = ranksum(spks{1},spks{2});
end
%%

figure;
inx = find(h<0.05);

for i = 1:length(req_params.cell_type)
        
    indType = intersect(inx,find(strcmp(req_params.cell_type{i}, cellType)));

    subplot(length(req_params.cell_type),1,i); hold on

    ave = mean(psthLow(indType,:));
    sem = nanSEM(psthLow(indType,:));
    errorbar(ts,ave,sem,'r');

    ave = mean(psthHigh(indType,:));
    sem = nanSEM(psthHigh(indType,:));
    errorbar(ts,ave,sem,'b');

    xlabel('Time from cue (ms)')
    ylabel('\Delta Rate')
    title([req_params.cell_type{i} ', n = ' num2str(length(indType))...
        '/' num2str(sum(strcmp(req_params.cell_type{i}, cellType)))])
    legend('Low','High')

end

