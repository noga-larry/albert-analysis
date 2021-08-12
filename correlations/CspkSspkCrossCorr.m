clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_INDIVIDUAL = 0;
runningWindow = -50:100; %ms  

req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;
req_params.remove_repeats = false;

lines = findCspkSspkPairs(task_info,req_params)

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(1,ii),lines(2,ii)]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    
    cc(ii,:) = crossCorrelogram(data2,data1,runningWindow);
    
    if PLOT_INDIVIDUAL
        plot(runningWindow,cc(ii,:));
        pause
    end
 
end


plot(runningWindow,nanmean(cc))

ylabel('Rate (Hz)')
xlabel('Time from Cspk (ms)')
title([req_params.cell_type ', n = ' num2str(length(pairs))])