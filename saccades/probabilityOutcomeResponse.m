
clear all;
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000; 
% req_params.ID = setdiff(4000:5000,[4243,4269,4575,4692,4718,4722])
req_params.num_trials = 20;
req_params.remove_question_marks = 1;


raster_params.align_to = 'reward';
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
    baseline = mean(raster2psth(rasterLowR,raster_params));
    
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
ylabel('Cspk rate (spk/s)')
legend('25','75')
title('Reward')

subplot(2,1,2);
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveHighNR,semLowNR,'b'); hold on
xlabel('Time for reward')
ylabel('Cspk rate (spk/s)')
legend('25','75')
title('No Reward')


figure;
subplot(2,1,1);
scatter(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2));
p = signrank(mean(psthHighR(:,compsrison_window),2),mean(psthLowR(:,compsrison_window),2));

refline(1,0)
xlabel('75');ylabel('25')
title(['Reward p=' num2str(p) ', n=' num2str(length(cells))])


subplot(2,1,2); 
scatter(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2));
p = signrank(mean(psthHighNR(:,compsrison_window),2),mean(psthLowNR(:,compsrison_window),2));
refline(1,0)
xlabel('75');ylabel('25')
title(['No Reward: p=' num2str(p) ', n=' num2str(length(cells))])

%% Make list of cells that responded to reward

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials =20;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'reward';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;
raster_params.SD = 10;
req_params.remove_question_marks =1;

cells = findPathsToCells (supPath,task_info,req_params);


cellID =[];

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    
    rasterLowR = getRaster(data,indLowR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    
    [~,h] = ranksum(sum(rasterLowR),sum(rasterHighR));
    if h
        cellID = [cellID, data.info.cell_ID]
    end

    

end



