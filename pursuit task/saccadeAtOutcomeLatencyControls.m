clear all

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss|BG|SNR';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 5000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 0;

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

raster_params.align_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

compsrison_window = raster_params.time_before + (100:300);

ts = -raster_params.time_before:raster_params.time_after;

windowEvent = -behavior_params.time_before:behavior_params.time_after;
directionBorders = 0:45:360;
timeAfterRewardForDirectionHist = 500; 

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

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

    FirstSaccadeLatency = nan(length(data.trials),1);
    for t=find(~boolFail)
        
        if data.trials(t).extended_trial_begin<1000 |...
                (length(data.trials(t).extended_vPos)-data.trials(t).trial_length...
                -data.trials(t).extended_trial_begin <2000)
            continue
        end
       
        saccadesAlignedToReward = data.trials(t).extended_saccade_begin...
            -data.trials(t).rwd_time_in_extended ;
        saccadesAfterReward = saccadesAlignedToReward(saccadesAlignedToReward>0);
        if isempty(saccadesAfterReward)
            FirstSaccadeLatency(t) = NaN;
            disp('No saccade')
            continue
        end
        FirstSaccadeLatency(t) = min(saccadesAfterReward);
       
    end
    

    latency(1,ii) = nanmedian(FirstSaccadeLatency(indLowR));
    latency(2,ii) = nanmedian(FirstSaccadeLatency(indHighR));
    latency(3,ii) = nanmedian(FirstSaccadeLatency(indLowNR));
    latency(4,ii) = nanmedian(FirstSaccadeLatency(indHighNR));
    
    
   
end

%%
figure
subplot(2,1,1)
scatter(latencyLowR,latencyLowNR)
p = signrank(latencyLowR,latencyLowNR);
refline(1,0)
xlabel('R'); ylabel('NR'); title(['25, p = ' num2str(p)])
subplot(2,1,2)
scatter(latencyHighR,latencyHighNR)
p = signrank(latencyHighR,latencyHighNR);
refline(1,0)
xlabel('R'); ylabel('NR'); title(['75, p = ' num2str(p)])
%%
ind = find(latencyLowR<latencyHighR);

aveLowR = nanmean(psthLowR(ind,:));
semLowR =  nanstd(psthLowR(ind,:))/sqrt(length(ind));
aveHighR = nanmean(psthHighR(ind,:));
semHighR = nanstd(psthHighR(ind,:))/sqrt(length(ind));

aveLowNR = nanmean(psthLowNR(ind,:));
semLowNR = nanstd(psthLowNR(ind,:))/sqrt(length(ind));
aveHighNR = nanmean(psthHighNR(ind,:));
semHighNR = nanstd(psthHighNR(ind,:))/sqrt(length(ind));

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
scatter(mean(psthHighR(ind,compsrison_window),2),mean(psthLowR(ind,compsrison_window),2));
refline(1,0)
xlabel('75');ylabel('25')
title('Reward')
p = signrank(mean(psthHighR(ind,compsrison_window),2),mean(psthLowR(ind,compsrison_window),2))
title(['Reward: p=' num2str(p) ', n=' num2str(length(ind))])



subplot(2,1,2);
scatter(mean(psthHighNR(ind,compsrison_window),2),mean(psthLowNR(ind,compsrison_window),2))
refline(1,0)
xlabel('75');ylabel('25')
p = signrank(mean(psthHighNR(ind,compsrison_window),2),mean(psthLowNR(ind,compsrison_window),2))
title(['No Reward: p=' num2str(p) ', n=' num2str(length(ind))])