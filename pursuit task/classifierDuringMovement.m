
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

FRAC_TEST = 0.2; 

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));

for ii = 1:length(cells)
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);    
    
    p = randperm(N,ceil(N*(1-FRAC_TEST)));
    training_set = raster(:,p);
    training_labels = match_d(p);
    test_set = raster; test_set(:,p)=[];
    test_labels = match_d; test_labels(p)=[];
    
    mdl = PsthAsEmClassifierModel;
    mdl = mdl.train(training_set,training_labels);
    accuracy(ii) = mdl.evaluate(test_set,test_labels);

end