clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_INDIVIDUAL = 0;
runningWindow = -300:300; %ms  

req_params.grade = 7;
%req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.num_trials = 20;
req_params.remove_repeats = false;

req_params.cell_type = 'PC cs';
lines1 = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC cs';
lines2 = findLinesInDB (task_info, req_params);
req_params.remove_question_marks = 1;

pairs = findPairs(task_info,lines1,lines2,req_params.num_trials);

for ii = 1:length(pairs)
    
    cells = findPathsToCells (supPath,task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    
    cc(ii,:) = crossCorrelogram(data1,data2,runningWindow);
    
    if PLOT_INDIVIDUAL
        plot(runningWindow,cc(ii,:));
        pause
    end
 
end


plot(runningWindow,nanmean(cc))

ylabel('Rate (Hz)')
xlabel('Time from Cspk (ms)')
title([req_params.cell_type ', n = ' num2str(length(pairs))])