clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Golda');

timeWindow = -200:200;
probabilities = [25,75];

raster_params.time_before = 200;
raster_params.time_after = 800;
raster_params.smoothing_margins = 200;
raster_params.align_to = 'cue';

corr_window = raster_params.time_before + (50:250);

req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;
req_params.remove_repeats = false;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';

req_params.cell_type = 'BG|SNR';
lines1 = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC ss|CRB';
lines2 = findLinesInDB (task_info, req_params);

pairs = findPairs(task_info,lines1,lines2,...
    req_params.num_trials);

ts = (-raster_params.time_before):(raster_params.time_after);

significanceInTime = nan(length(pairs),length(probabilities),...
    length(ts));
for ii = 1:length(pairs)
    
    cells = findPathsToCells (supPath,task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    [data1,data2] = reduceToSharedTrials(data1,data2);
    
    [~,match_p] = getProbabilities (data1);
    boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];
    
    for j=1:length(probabilities)
        
        ind = find (match_p == probabilities(j) & (~boolFail));
        
        raster1 = getRaster(data1,ind,raster_params);
        raster2 = getRaster(data2,ind,raster_params);

        for t = 1:length(ts)
            runningWindow = raster_params.smoothing_margins + t + timeWindow;
            spks1 = sum(raster1(runningWindow,:));
            spks2 = sum(raster2(runningWindow,:));
            
            
            [r,p]= corr(spks1(1:end-1)',spks2(2:end)');
            significanceInTime(ii,j,t) = p<0.05;
        end
        
        
    end
        
end

%%

fracSignificantInTime = squeeze(mean(significanceInTime));

figure; hold on
plot(ts,fracSignificantInTime(1,:),'r')
plot(ts,fracSignificantInTime(2,:),'b')

xlabel('Time from que')
ylabel('Frac significant')
legend('25','75')
