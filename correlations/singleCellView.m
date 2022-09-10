clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

SD = 15;

raster_params.time_before = 350;
raster_params.time_after = 800;
raster_params.SD = SD;
raster_params.smoothing_margins = SD*5;

corr_window = raster_params.time_before + (50:250);

req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;
req_params.remove_repeats = false;

req_params.cell_type = 'BG|SNR';
lines1 = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC ss|CRB'
lines2 = findLinesInDB (task_info, req_params);
req_params.remove_question_marks = 1;

pairs = findPairs(task_info,lines1,lines2,req_params.num_trials);

ts = (-raster_params.time_before):(raster_params.time_after);
%%

for ii = 1:length(pairs)
    
    cells = findPathsToCells (supPath,task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    [data1,data2] = reduceToSharedTrials(data1,data2);
    
    boolFail = [data2.trials.fail] ;
    ind = find (~boolFail);
    
    % cue
    raster_params.align_to = 'cue';
      
    psth1 =  getSTpsth(data1,ind,raster_params);
    psth2 =  getSTpsth(data2,ind,raster_params);
    
    subplot(3,1,1)
    imagesc(ts,ts,corr(psth1,psth2)); colorbar
    title ('Cue')
    xlabel('Time from cue onet')
    ylabel('Time from cue onet')

    % motion
    raster_params.align_to = 'targetMovementOnset';
      
    psth1 =  getSTpsth(data1,ind,raster_params);
    psth2 =  getSTpsth(data2,ind,raster_params);
    
    subplot(3,1,2)
    imagesc(ts,ts,corr(psth1,psth2)); colorbar
    title ('Motion')
    xlabel('Time from motion onet')
    ylabel('Time from motion onet')

    % reward

    raster_params.align_to = 'reward';

    psth1 =  getSTpsth(data1,ind,raster_params);
    psth2 =  getSTpsth(data2,ind,raster_params);

    subplot(3,1,3)
    imagesc(ts,ts,corr(psth1,psth2)); colorbar
    title ('Reward')
    xlabel('Time from reward onet')
    ylabel('Time from reward onet')
    
    sgtitle([ data1.info.cell_type ' ' num2str(data1.info.cell_ID) ...
        ' & ' data2.info.cell_type ' ' num2str(data2.info.cell_ID)])
       
    pause
end

