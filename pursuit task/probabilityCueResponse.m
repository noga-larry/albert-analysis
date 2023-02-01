% Probability Cue Response
clear; clc
[task_info, supPath ,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

% Make list of significant cells

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;
req_params.grade =7;
req_params.ID = 4000:6000;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.num_trials = 50;
req_params.remove_repeats = 0;


raster_params.align_to = 'cue';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells )
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] |~[data.trials.previous_completed] ;


    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));

    psthLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);

    spikesLow = sum(psthLow,1);
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
req_params.cell_type = 'SNR';
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
    psthLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);

    if ~strcmp(req_params.cell_type,'PC cs')
        baseline = mean(raster2psth(rasterBaseline,raster_params));
    else
        baseline = 0;
    end
    psthLow(ii,:) = raster2psth(psthLow,raster_params)-baseline;
    psthHigh(ii,:) = raster2psth(rasterHigh,raster_params)-baseline;
    h(ii) = task_info(lines(ii)).cue_differentiating;

end


f = figure;
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


for ii = 1:length(cells )

    data = importdata(cells{ii});

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

    baseline = mean(getPSTH(data,find(~boolFail),raster_params),1);

    for p=1:length(PROBABILITIES)
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        psths{p} = getPSTH(data,ind,raster_params) - baseline;
        rate(p) = mean(psths{p},1);
    end

    
    if rate(1)>rate(2)
        psthHigh(ii,:) = psths{1};
        psthLow(ii,:) = psths{2};
    else
        psthHigh(ii,:) = psths{2};
        psthLow(ii,:) = psths{1};
    end

end

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






