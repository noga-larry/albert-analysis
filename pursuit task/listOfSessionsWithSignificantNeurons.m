clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
BIN_SIZE = 100;

req_params.grade = 7;
cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_repeats = false;
req_params.remove_question_marks = 0;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0;

sessions = uniqueRowsCA({task_info.session}');
sessions_list = cell(1,length(cell_type));

for i = 1:length(sessions)
    
    req_params.session = sessions{i};
    
    for j = 1:length(cell_type)
        
        sig_flag = false;
        req_params.cell_type = cell_type{j};
        lines = findLinesInDB (task_info, req_params);
        cells = findPathsToCells (supPath,task_info,lines);
        
        for c = 1:length(cells)
            
            if sig_flag
                % The case that a significant cell was already found
                continue
            end
            
            data = importdata(cells{c});
            
            boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
            ind = find(~boolFail);
            [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
            [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
            
            raster = getRaster(data,find(~boolFail),raster_params);
            response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);
            
            groupT = repmat((1:size(response,1))',1,size(response,2));
            groupR = repmat(match_p',size(response,1),1);
            groupD = repmat(match_d',size(response,1),1);
            
%             p = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
%                 'model','interaction','display','off');
            try
            [d,p] = manova1(response',match_d);
            catch
                p = 1;
                disp(['Skip' data.info.cell_type])
            end
            
            if p(1)<0.001
               sig_flag = true;
            end
        end
        
        if sig_flag
            if ismember(j,[1,2,3])
                sessions_list{1}(end+1) = sessions(i);
            else
                sessions_list{2}(end+1) = sessions(i);
            end
        end
    end  
end

sessionMap = containers.Map('KeyType','char','ValueType','any');

sessionMap('Vermis') = uniqueRowsCA(sessions_list{1}');
sessionMap('BG') = uniqueRowsCA(sessions_list{2}');
