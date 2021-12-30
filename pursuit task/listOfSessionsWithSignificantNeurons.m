clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
BIN_SIZE = 50;

req_params.grade = 7;
cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';req_params.ID = 4000:6000;
req_params.num_trials = 30;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

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
            
            p = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
                'model','interaction','display','off');
            
            if p(3)<0.05 | p(5)<0.05
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
