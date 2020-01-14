
req_params.grade = 10;
req_params.cell_type = 'CRB|PC|BG|SNR';
req_params.task = 'speed_2_dir_0,50,100|pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.remove_question_marks = 0;
req_params.ID = 4000:5000;
req_params.remove_question_marks = 0;
req_params.num_trials = 40;

sessions = uniqueRowsCA({task_info.session}');


for ii=1:length(sessions)
    req_params.session = sessions{ii};
    lines = findLinesInDB (task_info, req_params);
    
    for c = 1:length(lines)
        listOfCells = [];
        fb1 = task_info(lines(c)).fb_after_sort;
        fe1 = task_info(lines(c)).fe_after_sort;
        trial1 = fb1:fe1;
        
        for d = 1:length(lines)
            fb2 = task_info(lines(d)).fb_after_sort;
            fe2 = task_info(lines(d)).fe_after_sort;
            trials2 = fb2:fe2;
            
            if length(intersect(trial1,trials2)) >= req_params.num_trials...
                    & ~(task_info(lines(c)).cell_ID == task_info(lines(d)).cell_ID)...
                    & ~(task_info(lines(c)).electrode == task_info(lines(d)).electrode)
                
                    
            
                listOfCells = [listOfCells lines(d)];
            end
            
        end
        
        task_info(lines(c)).cell_recorded_simultaneously = listOfCells;
    end
end


save('C:\noga\TD complex spike analysis\task_info','task_info')
