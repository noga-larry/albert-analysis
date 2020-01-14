supPath = 'C:\noga\TD complex spike analysis\Data\albert\speed_2_dir_0,50,100';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000; 
req_params.num_trials =20;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'reward';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;
compsrison_window = raster_params.time_before + (100:300); 

ts = -raster_params.time_before:raster_params.time_after;

cells = findPathsToCells (supPath,task_info,req_params);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];
    
    indLowNR = find (match_p == 0 & (~match_o) & (~boolFail));
    indMidR = find (match_p == 50 & match_o & (~boolFail));
    indMidNR = find (match_p == 50 & (~match_o) & (~boolFail));
    indHighR = find (match_p == 100 & match_o & (~boolFail));
    
    rasterLowNR = getRaster(data,indLowNR,raster_params);
    rasterMidNR = getRaster(data,indMidNR,raster_params);
    rasterMidR = getRaster(data,indMidR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    
    psthLowNR(ii,:) = raster2psth(rasterLowNR,raster_params);
    psthMidNR(ii,:) = raster2psth(rasterMidNR,raster_params);
    psthMidR(ii,:) = raster2psth(rasterMidR,raster_params);
    psthHighR(ii,:) = raster2psth(rasterHighR,raster_params);
end
%%
aveMidR = mean(psthMidR);
semMidR = std(psthMidR)/sqrt(length(cells));
aveHighR = mean(psthHighR);
semHighR = std(psthHighR)/sqrt(length(cells));

aveLowNR = mean(psthLowNR);
semLowNR = std(psthLowNR)/sqrt(length(cells));
aveMidNR = mean(psthMidNR);
semMidNR = std(psthMidNR)/sqrt(length(cells));

figure;
subplot(2,1,1); title('Reward')
errorbar(ts,aveMidR,semMidR,'k'); hold on
errorbar(ts,aveHighR,semHighR,'b'); hold on
xlabel('Time for reward')
ylabel('Rate (spk/s)')
legend('50','100')

subplot(2,1,2); title('No Reward')
errorbar(ts,aveLowNR,semLowNR,'r'); hold on
errorbar(ts,aveMidNR,semMidNR,'k'); hold on
xlabel('Time for reward')
ylabel('Cspk rate (spk/s)')
legend('0','50')


figure;
subplot(2,1,1);
scatter(mean(psthHighR(:,compsrison_window),2),mean(psthMidR(:,compsrison_window),2));
refline(1,0)
xlabel('100');ylabel('50')
 title('Reward')


subplot(2,1,2); 
scatter(mean(psthLowNR(:,compsrison_window),2),mean(psthMidNR(:,compsrison_window),2));
refline(1,0)
xlabel('0');ylabel('50')
title('No Reward')

%% Make list of cells that responded to reward

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'pursuit_8_dir_75and25';
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



