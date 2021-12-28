clear all

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'SNR|BG|PC|CRB';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 400;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data_my_format = importdata(cells{ii});
    cell_ID  = [data_my_format.info.cell_ID];
    boolFail = [data_my_format.trials.fail];
    
    ind = find(~boolFail);
    raster = getRaster(data_my_format,ind,raster_params);
    data.spikes = sparse(raster);
        
    [~,match_d] = getDirections(data_my_format,ind);
    match_d = match_d(ind);
    data.target_direction = match_d;
    
    [~,match_p] = getProbabilities (data_my_format,ind);
    match_p = match_p(ind);
    data.reward_probability = match_p;
    
    data.target_change = [400]; 
    
    data.trial_name = {data_my_format.trials(ind).name};
    
    save(['G:\DataForYoavAndShay\cue' '\' req_params.task '\' data_my_format.info.cell_type '_' ...
        num2str(data_my_format.info.cell_ID)], 'data')
end