clear; clc
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = [25 75];
OUTCOMES = [0 1];
DIRECTIONS = 0:45:315;
COMP_WINDOW = 0:700;

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.remove_question_marks = 1;
req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.num_trials = 120;
req_params.remove_repeats = 1;
req_params.ID = 4000:6000;

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before:raster_params.time_after;
psthPD = nan(length(cells),length(PROBABILITIES),...
    length(OUTCOMES),length(ts));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities(data);
    match_o = getOutcome(data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    condCounter =0;
    
    ind = find(~boolFail); 
    
    [TCAllCond,~,isTunedVec(ii)] = getTC(data,DIRECTIONS,ind,COMP_WINDOW);
    PD = centerOfMass (TCAllCond, DIRECTIONS);
    TCbaseline = mean(TCAllCond);
    
    % PSTH baseline
    ind = find(~boolFail & match_d==PD);
    psthBaseline = mean(getPSTH(data,ind,raster_params));            
    
    for p = 1:length(PROBABILITIES)
        for j = 1:length(OUTCOMES)
            condCounter = condCounter+1;
            ind = find(~boolFail & match_p==PROBABILITIES(p) & ...
                match_o == OUTCOMES(j));
            TC = getTC(data,DIRECTIONS,ind,COMP_WINDOW,'alignTo','reward');
            alignedTCs(ii,p,j,:) = alignTC2PD(TC,DIRECTIONS) - TCbaseline;
            
            % PSTH in the PD
            ind = find(~boolFail & match_p==PROBABILITIES(p) & ...
                match_o == OUTCOMES(j) & match_d==PD);
            psth = getPSTH(data,ind,raster_params);
            psthPD(ii,p,j,:) = psth - psthBaseline;
        end
    end
    
end

%%
figure;
lineStyle = {'r*-','ro--','b*-','bo--'};

subplot(3,1,1)
outcomeTCplot(alignedTCs,PROBABILITIES,OUTCOMES,lineStyle)
title(['All cells, n = ' num2str(length(isTunedVec))])

subplot(3,1,2)
ind = find(isTunedVec);
outcomeTCplot(alignedTCs(ind,:,:,:),PROBABILITIES,OUTCOMES,lineStyle)
title(['Tuned, n = ' num2str(length(ind))])

subplot(3,1,3)
ind = find(~isTunedVec);
outcomeTCplot(alignedTCs(ind,:,:,:),PROBABILITIES,OUTCOMES,lineStyle)
title(['Not tuned, n = ' num2str(length(ind))])
sgtitle(req_params.cell_type)

figure;
lineStyle = {'r-','r--','b-','b--'};

subplot(3,1,1)
outcomePSTHplot(psthPD,ts,PROBABILITIES,OUTCOMES,lineStyle)
title(['All cells, n = ' num2str(length(isTunedVec))])

subplot(3,1,2)
ind = find(isTunedVec);
outcomePSTHplot(psthPD(ind,:,:,:),ts,PROBABILITIES,OUTCOMES,lineStyle)
title(['Tuned, n = ' num2str(length(ind))])

subplot(3,1,3)
ind = find(~isTunedVec);
outcomePSTHplot(psthPD(ind,:,:,:),ts,PROBABILITIES,OUTCOMES,lineStyle)
title(['Not tuned, n = ' num2str(length(ind))])
sgtitle(req_params.cell_type)

%%
function outcomeTCplot(alignedTCs,probabilities,outcomes,lineStyle)
hold on
angles = -180:45:180;
condCounter =0;
for p=1:length(probabilities)
    for j=1:length(outcomes)
        condCounter = condCounter+1;
        ave = squeeze(nanmean(alignedTCs(:,p,j,:)));
        sem = squeeze(nanSEM(alignedTCs(:,p,j,:)));
        errorbar(angles,ave,sem,lineStyle{condCounter})
    end
end
xlabel('Angle from PD')
ylabel(['\Delta FR '])

legend('25 NR', '25 R', '75 NR', '75 R')
end


%%
function outcomePSTHplot(psth,ts,probabilities,outcomes,lineStyle)
hold on
condCounter =0;
for p=1:length(probabilities)
    for j=1:length(outcomes)
        condCounter = condCounter+1;
        plot(ts,squeeze(nanmean(psth(:,p,j,:))),lineStyle{condCounter})
    end
end
xlabel('time from reward')
ylabel(['\Delta FR '])

legend('25 NR', '25 R', '75 NR', '75 R')
end
