%% cue

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;


lines = findLinesInDB(task_info,req_params);
fitInd = cellfun(@(c) c==0,{task_info(lines).extended_behavior_fit},'uni',false);
fitInd = [fitInd{:}];
fitInd = find(fitInd);
lines = lines(fitInd);

cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities(data);
    boolFail = [data.trials.fail];
    
    indLow = find(match_p == 25 & (~boolFail));
    indHigh = find(match_p == 75 & (~boolFail));
    
    saccadeRate = nan(length(data.trials),length(windowEvent));
    for t = find(~boolFail)
        
        if data.trials(t).extended_trial_begin<1000
            continue
        end
        saccadeTrace = zeros(1,length(data.trials(t).extended_hVel));
        saccadeTrace(data.trials(t).extended_saccade_begin) = 1;
        ts = data.trials(t).cue_onset + data.trials(t).extended_trial_begin + windowEvent;
        saccadeRate(t,:) = saccadeTrace(ts);
        
    end
    
    saccadesLow(ii,:) = gaussSmooth(nanmean(saccadeRate(indLow,:)),behavior_params.SD);
    saccadesHigh(ii,:) = gaussSmooth(nanmean(saccadeRate(indHigh,:)),behavior_params.SD);
    
    
end
    

aveLow = mean(saccadesLow);
aveHigh = mean(saccadesHigh);
semLow = std(saccadesLow)/sqrt(length(cells));
semHigh = std(saccadesHigh)/sqrt(length(cells));

figure;
errorbar(windowEvent,aveLow,semLow,'r'); hold on
errorbar(windowEvent,aveHigh,semHigh,'b')
xlabel('Time from cue')
ylabel('Fraction of trials with saccade')

%% reward
clear all

MaestroPath = 'C:\Users\Noga\Music\DATA';
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

raster_params.align_to = 'reward';
raster_params.time_before = -100;
raster_params.time_after =300;
raster_params.smoothing_margins = 0;

windowEvent = -behavior_params.time_before:behavior_params.time_after;
directionBorders = 0:45:360;
timeAfterRewardForDirectionHist = 500; 

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

sc = 0;
removeSaccadesCounter = 0;
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowR = find (match_p == 25 & match_o == 1 &(~boolFail));
    indHighR = find (match_p == 75 & match_o == 1 & (~boolFail));
    indLowNR = find (match_p == 25 & match_o == 0 &(~boolFail));
    indHighNR = find (match_p == 75 & match_o == 0 &(~boolFail));
    
    saccadeRate = nan(length(data.trials),length(windowEvent));
    blinkRate = nan(length(data.trials),length(windowEvent));

    FirstSaccadeLatency = nan(length(data.trials));
    directionHist= nan(length(data.trials),length(directionBorders)-1);
    saccdeSpeed = nan(length(data.trials));
    for t=find(~boolFail)
        
        if data.trials(t).extended_trial_begin<1000 |...
                (length(data.trials(t).extended_vPos)-data.trials(t).trial_length...
                -data.trials(t).extended_trial_begin <2000)
            continue
        end
        
        % rate
        saccadeTrace = zeros(1,length(data.trials(t).extended_hVel));
        blinkTrace = zeros(1,length(data.trials(t).extended_hVel));
        
        saccadeTrace(data.trials(t).extended_saccade_begin) = 1;
        blinkTrace(data.trials(t).extended_blink_begin) = 1;
        
        ts = data.trials(t).rwd_time_in_extended + windowEvent;
        saccadeRate(t,:) = saccadeTrace(ts);
        blinkRate(t,:) = blinkTrace(ts);
        % latency
        saccadesAlignedToReward = data.trials(t).extended_saccade_begin...
            -data.trials(t).rwd_time_in_extended ;
        saccadesAfterReward = saccadesAlignedToReward(saccadesAlignedToReward>0);
        if isempty(saccadesAfterReward) | min(saccadesAfterReward)>1000
            disp('No saccade')
            continue
        end
        FirstSaccadeLatency(t) = min(saccadesAfterReward);
        
        % direction hist
        saccasdesIndsForDirectionHist = find(saccadesAlignedToReward>0 &...
        saccadesAlignedToReward<timeAfterRewardForDirectionHist);
        trialDirectionHist = zeros(1,length(directionBorders)-1);
        trialSpeed = 0; saccCounter=0;
        for s =1:length(saccasdesIndsForDirectionHist)
            i = saccasdesIndsForDirectionHist(s);
            tb = data.trials(t).extended_saccade_begin( i);
            te = data.trials(t).extended_saccade_end( i);
            if ~isempty(data.trials(t).extended_blink_begin) &&...
                    any((data.trials(t).extended_blink_begin>=tb & data.trials(t).extended_blink_end<=te )...
                    | (data.trials(t).extended_blink_begin<=tb & data.trials(t).extended_blink_end>=te) )
                removeSaccadesCounter = removeSaccadesCounter+1;
                continue
            end
            deltaH = data.trials(t).extended_hPos(te) - data.trials(t).extended_hPos(tb);
            deltaV = data.trials(t).extended_vPos(te) - data.trials(t).extended_vPos(tb);
            phi = atan2d(deltaV,deltaH);
            phi = phi + 360*(phi<0);
            trialDirectionHist = trialDirectionHist+diff(phi<directionBorders);
            trialSpeed = trialSpeed + sqrt(deltaH^2+deltaV^2);
            saccCounter = saccCounter+1;
            sc= sc+1;
        end
        directionHist(t,:) = trialDirectionHist;
        trialSpeed = trialSpeed/saccCounter;
        saccdeSpeed(t,:) = trialSpeed;
        
    end
    
    saccadeRateLowR(ii,:) = gaussSmooth(nanmean(saccadeRate(indLowR,:)),behavior_params.SD);
    saccadeRateHighR(ii,:) = gaussSmooth(nanmean(saccadeRate(indHighR,:)),behavior_params.SD);
    saccadeRateLowNR(ii,:) = gaussSmooth(nanmean(saccadeRate(indLowNR,:)),behavior_params.SD);
    saccadeRateHighNR(ii,:) = gaussSmooth(nanmean(saccadeRate(indHighNR,:)),behavior_params.SD);
    
    blinkRateLowR(ii,:) = gaussSmooth(nanmean(blinkRate(indLowR,:)),behavior_params.SD);
    blinkRateHighR(ii,:) = gaussSmooth(nanmean(blinkRate(indHighR,:)),behavior_params.SD);
    blinkRateLowNR(ii,:) = gaussSmooth(nanmean(blinkRate(indLowNR,:)),behavior_params.SD);
    blinkRateHighNR(ii,:) = gaussSmooth(nanmean(blinkRate(indHighNR,:)),behavior_params.SD);
    
    
    latencyLowR(ii) = nanmean(FirstSaccadeLatency(indLowR));
    latencyHighR(ii) = nanmean(FirstSaccadeLatency(indHighR));
    latencyLowNR(ii) = nanmean(FirstSaccadeLatency(indLowNR));
    latencyHighNR(ii) = nanmean(FirstSaccadeLatency(indHighNR));
    
    latencyVarLowR(ii) = nanstd(FirstSaccadeLatency(indLowR));
    latencyVarHighR(ii) = nanstd(FirstSaccadeLatency(indHighR));
    latencyVarLowNR(ii) = nanstd(FirstSaccadeLatency(indLowNR));
    latencyVarHighNR(ii) = nanstd(FirstSaccadeLatency(indHighNR));
    
    speedLowR(ii) = nanmean(saccdeSpeed(indLowR));
    speedHighR(ii) = nanmean(saccdeSpeed(indHighR));
    speedLowNR(ii) = nanmean(saccdeSpeed(indLowNR));
    speedHighNR(ii) = nanmean(saccdeSpeed(indHighNR));
    
    
    directionHistLowR(ii,:) = nansum(directionHist(indLowR,:))/nansum(nansum(directionHist(indLowR,:)));
    directionHistHighR(ii,:) = nansum(directionHist(indHighR,:))/nansum(nansum(directionHist(indHighR,:)));
    directionHistLowNR(ii,:) = nansum(directionHist(indLowNR,:))/nansum(nansum(directionHist(indLowNR,:)));
    directionHistHighNR(ii,:) = nansum(directionHist(indHighNR,:))/nansum(nansum(directionHist(indHighNR,:)));
    
   
    rasterLowR = getRaster(data,indLowR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    
    rewardSpikesDifference(ii) = (mean(rasterLowR(:))-mean(rasterHighR(:)))*1000;
    rewardLatencyDidderence(ii) = latencyLowR(ii)-latencyHighR(ii);
    
    
end
    
%%
aveLowR = nanmean(saccadeRateLowR);
aveHighR = mean(saccadeRateHighR);
semLowR = nanstd(saccadeRateLowR)/sqrt(length(cells));
semHighR = std(saccadeRateHighR)/sqrt(length(cells));
aveLowNR = mean(saccadeRateLowNR);
aveHighNR = mean(saccadeRateHighNR);
semLowNR = std(saccadeRateLowNR)/sqrt(length(cells));
semHighNR = std(saccadeRateHighNR)/sqrt(length(cells));

figure;
subplot(2,1,1)
errorbar(windowEvent,aveLowR,semLowR,'r'); hold on
errorbar(windowEvent,aveHighR,semHighR,'b')
xlabel('Time from Reward')
ylabel('Fraction of trials')
legend ('25','75')
title('Reward')

subplot(2,1,2)
errorbar(windowEvent,aveLowNR,semLowNR,'r'); hold on
errorbar(windowEvent,aveHighNR,semHighNR,'b')
title('No Reward')
legend ('25','75')


aveLowR = nanmean(blinkRateLowR);
aveHighR = mean(blinkRateHighR);
semLowR = nanstd(blinkRateLowR)/sqrt(length(cells));
semHighR = std(blinkRateHighR)/sqrt(length(cells));
aveLowNR = mean(blinkRateLowNR);
aveHighNR = mean(blinkRateHighNR);
semLowNR = std(blinkRateLowNR)/sqrt(length(cells));
semHighNR = std(blinkRateHighNR)/sqrt(length(cells));

figure;
subplot(2,1,1)
errorbar(windowEvent,aveLowR,semLowR,'r'); hold on
errorbar(windowEvent,aveHighR,semHighR,'b')
xlabel('Time from Reward')
ylabel('Fraction of trials')
legend ('25','75')
title('Reward')

subplot(2,1,2)
errorbar(windowEvent,aveLowNR,semLowNR,'r'); hold on
errorbar(windowEvent,aveHighNR,semHighNR,'b')
title('No Reward')
legend ('25','75')



figure;
subplot(3,1,1)
plot(1,latencyLowR,'ro'); hold on
plot(2,latencyLowNR,'ro'); hold on
plot(3,latencyHighR,'bo'); hold on
plot(4,latencyHighNR,'bo'); hold on
plot(1,nanmean(latencyLowR),'ko','MarkerSize',10); hold on
plot(2,nanmean(latencyLowNR),'ko','MarkerSize',10);
plot(3,nanmean(latencyHighR),'ko','MarkerSize',10);
plot(4,nanmean(latencyHighNR),'ko','MarkerSize',10);
xticks([1:4])
xticklabels({'25R','25NR','75R','75NR'})


subplot(3,1,2)
scatter(latencyHighR,latencyLowR);hold on
scatter(latencyHighNR,latencyLowNR);refline(1,0)
xlabel('p=75')
ylabel('P=25')
legend('R','NR')
p1 = signrank(latencyHighNR,latencyLowNR);
p2 = signrank(latencyHighR,latencyLowR);
title(['R: p=' num2str(p2) ', NR: p = ' num2str(p1) ])

subplot(3,1,3)
scatter(latencyHighR,latencyHighNR);hold on
scatter(latencyLowR,latencyLowNR);refline(1,0)
xlabel('R')
ylabel('NR')
legend('P=75','P=25')
p1 = signrank(latencyHighR,latencyHighNR);
p2 = signrank(latencyLowR,latencyLowNR);
title(['75: p=' num2str(p2) ', 25: p = ' num2str(p1) ])

figure; 

scatter(latencyVarHighR,latencyVarLowR);hold on
scatter(latencyVarHighNR,latencyVarLowNR);refline(1,0)
xlabel('Latency std p=75')
ylabel('Latency std P=25')
legend('R','NR')
p1 = signrank(latencyVarHighNR,latencyVarLowNR);
p2 = signrank(latencyVarHighR,latencyVarLowR);
title(['R: p=' num2str(p2) ', NR: p = ' num2str(p1) ])



figure;
errorbar(directionBorders(1:8),nanmean(directionHistLowR),nanstd(directionHistLowR)/length(cells),'r'); hold on
errorbar(directionBorders(1:8),nanmean(directionHistLowNR),nanstd(directionHistLowNR)/length(cells),'--r'); hold on
errorbar(directionBorders(1:8),nanmean(directionHistHighR),nanstd(directionHistHighR)/length(cells),'b'); hold on
errorbar(directionBorders(1:8),nanmean(directionHistHighNR),nanstd(directionHistHighNR)/length(cells),'--b'); hold on
legend({'25R','25NR','75R','75NR'})
xlabel('direction')
ylabel('fraction of saccades')


figure;
scatter(rewardLatencyDidderence,rewardSpikesDifference);
[r,p] = corr(rewardLatencyDidderence',rewardSpikesDifference','type','Spearman','Rows','Pairwise');
title(['r = ' num2str(r) ', p = ' num2str(p)])
xlabel('Latency 25-75')
ylabel('spikes 25-75')

figure;
scatter(speedHighR,speedLowR);hold on
scatter(speedHighNR,speedLowNR);hold on;
ylabel('speed P=75')
xlabel('sepeed P=25')
legend('R','NR')
p1 = signrank(speedHighR,speedLowR);
p2 = signrank(speedHighNR,speedLowNR);
title(['R: p=' num2str(p1) ', NR: p = ' num2str(p2) ])
refline(1,0)


%% GLME
%latnecy
for ii=1:length(cells)
    cell_ID_for_GLM(4*(ii-1)+1:4*ii) = task_info(lines(ii)).cell_ID;
    reward_for_GLM{4*(ii-1)+1} = 'R';
    reward_for_GLM{4*(ii-1)+2} = 'R';
    reward_for_GLM{4*(ii-1)+3} = 'NR';
    reward_for_GLM{4*(ii-1)+4} = 'NR';
    prob_for_GLM{4*(ii-1)+1} = '25';
    prob_for_GLM{4*(ii-1)+2} = '75';
    prob_for_GLM{4*(ii-1)+3} = '25';
    prob_for_GLM{4*(ii-1)+4} = '75';
    latency_for_GLM(4*(ii-1)+1) = latencyLowR(ii);
    latency_for_GLM(4*(ii-1)+2) = latencyHighR(ii);
    latency_for_GLM(4*(ii-1)+3) = latencyLowNR(ii);
    latency_for_GLM(4*(ii-1)+4) = latencyHighNR(ii);
end

glm_tbl = table(cell_ID_for_GLM',reward_for_GLM',prob_for_GLM',latency_for_GLM',...
    'VariableNames',{'ID','reward','prob','latency'});
glme = fitglme(glm_tbl,...
'latency ~ 1  +  prob+ reward  + prob*reward + (1|ID)','DummyVarCoding','effects')

% direction
for ii=1:length(cells)
    cell_ID_for_GLM(8*4*(ii-1)+1:4*ii) = task_info(lines(ii)).cell_ID;
    reward_for_GLM{8*4*(ii-1)+1} = 'R';
    reward_for_GLM{8*4*(ii-1)+2} = 'R';
    reward_for_GLM{8*4*(ii-1)+3} = 'NR';
    reward_for_GLM{8*4*(ii-1)+4} = 'NR';
    prob_for_GLM{8*4*(ii-1)+1} = '25';
    prob_for_GLM{8*4*(ii-1)+2} = '75';
    prob_for_GLM{8*4*(ii-1)+3} = '25';
    prob_for_GLM{4*(ii-1)+4} = '75';
    latency_for_GLM(4*(ii-1)+1) = latencyLowR(ii);
    latency_for_GLM(4*(ii-1)+2) = latencyHighR(ii);
    latency_for_GLM(4*(ii-1)+3) = latencyLowNR(ii);
    latency_for_GLM(4*(ii-1)+4) = latencyHighNR(ii);
end

glm_tbl = table(cell_ID_for_GLM',reward_for_GLM',prob_for_GLM',latency_for_GLM',...
    'VariableNames',{'ID','reward','prob','latency'});
glme = fitglme(glm_tbl,...
'latency ~ 1  +  prob+ reward  + prob*reward + (1|ID)','DummyVarCoding','effects')
    
