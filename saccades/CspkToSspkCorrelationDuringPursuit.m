% Probability Tuning curves
supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


bool_task = ~cellfun(@isempty,regexp({task_info.task},'saccade_8_dir_75and25'));
bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC cs'));
bool_grade = [task_info.grade] <= 6;
bool_nt = [task_info.num_trials] > 50;
IDCspks = [task_info(find(bool_task & bool_type & bool_grade &bool_nt)).cell_ID];

bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC ss'));
IDSspks = [task_info(find(bool_task & bool_type & bool_grade &bool_nt)).cell_ID];
cellIDs = intersect(IDSspks,IDCspks);

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
comparison_window = 100:300; % for TC
ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;

req_params.task = 'saccade_8_dir_75and25';
req_params.remove_question_marks = 1;



for ii = 1:length(cellIDs)
    req_params.ID = cellIDs(ii);
    req_params.cell_type = 'PC ss';
    
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataSspk = importdata(path{:});
    req_params.cell_type = 'PC cs';
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataCspk = importdata(path{:});
      
   
    [TCSspks,~,h(ii)] = getTC(dataSspk, directions,1:length(dataSspk.trials), comparison_window);
    [TCCspks,~,h(ii)] = getTC(dataCspk, directions,1:length(dataCspk.trials), comparison_window);
    [PD,indPD] = centerOfMass (TCSspks, directions);

    popTCSspks(ii,:) = circshift(TCSspks,5-indPD)-mean(TCSspks);
    popTCCspks(ii,:) = circshift(TCCspks,5-indPD);
    
    rho(ii) = corr(popTCSspks(ii,:)', popTCCspks(ii,:)');
    
       
    
    
end

%%
figure;
aveSspk = nanmean(popTCSspks);
semSspk = nanstd(popTCSspks)/sqrt(length(cellIDs));
aveCspk = nanmean(popTCCspks);
semCspk = nanstd(popTCCspks)/sqrt(length(cellIDs));
subplot(2,1,1)
errorbar(directions,aveSspk,semSspk,'k'); hold on
xlabel('direction')
title('Spks')
subplot(2,1,2)
errorbar(directions,aveCspk,semCspk,'k'); hold on
title('Cpks')
xlabel('direction')

figure;
hist(rho,10)
signrank(rho)



%% Herzfeld

supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


bool_task = ~cellfun(@isempty,regexp({task_info.task},'saccade_8_dir_75and25'));
bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC cs'));
bool_grade = [task_info.grade] <= 7;
bool_nt = [task_info.num_trials] > 50;
bool_qm = cellfun(@isempty,regexp({task_info.cell_type},'?'));
IDCspks = [task_info(find(bool_task & bool_type & bool_grade &bool_nt &bool_qm)).cell_ID];

bool_type = ~cellfun(@isempty,regexp({task_info.cell_type},'PC ss'));
IDSspks = [task_info(find(bool_task & bool_type & bool_grade &bool_nt &bool_qm)).cell_ID];
cellIDs = intersect(IDSspks,IDCspks);

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
comparison_window = 100:300; % for TC
ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;

req_params.task = 'saccade_8_dir_75and25';
req_params.remove_question_marks = 1;



for ii = 1:length(cellIDs)
    req_params.ID = cellIDs(ii);
    req_params.cell_type = 'PC ss';
    
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataSspk = importdata(path{:});
    req_params.cell_type = 'PC cs';
    line = findLinesInDB (task_info, req_params);
    path = findPathsToCells (supPath,task_info,line);
    dataCspk = importdata(path{:});
      
   
    [TCSspks,~,h(ii)] = getTC(dataSspk, directions,1:length(dataSspk.trials), comparison_window);
    [TCCspks,~,~] = getTC(dataCspk, directions,1:length(dataCspk.trials), comparison_window);
    [PD,indPD] = centerOfMass (TCCspks, directions);

    popTCSspks(ii,:) = circshift(TCSspks,5-indPD)-mean(TCSspks);
    popTCCspks(ii,:) = circshift(TCCspks,5-indPD);
    
    rho(ii) = corr(popTCSspks(ii,:)', popTCCspks(ii,:)');
    
       
    
    
end

%%
figure;
aveSspk = nanmean(popTCSspks);
semSspk = nanstd(popTCSspks)/sqrt(length(cellIDs));
aveCspk = nanmean(popTCCspks);
semCspk = nanstd(popTCCspks)/sqrt(length(cellIDs));
subplot(2,2,1)
errorbar(directions,aveSspk,semSspk,'k'); hold on
xlabel('direction')
title('Spks, All cells')
subplot(2,2,2)
errorbar(directions,aveCspk,semCspk,'k'); hold on
title('Cpks, All cells')
xlabel('direction')

indSig = find(h);
aveSspk = nanmean(popTCSspks(indSig,:));
semSspk = nanstd(popTCSspks(indSig,:))/sqrt(length(indSig));
aveCspk = nanmean(popTCCspks(indSig,:));
semCspk = nanstd(popTCCspks(indSig,:))/sqrt(length(indSig));
subplot(2,2,3)
errorbar(directions,aveSspk,semSspk,'k'); hold on
xlabel('direction')
title('Spks, Sig')
subplot(2,2,4)
errorbar(directions,aveCspk,semCspk,'k'); hold on
title('Cpks, Sig')
xlabel('direction')



figure;
hist(rho,10)
signrank(rho)


