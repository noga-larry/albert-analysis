
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

FRAC_TEST = 0.2; 

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = [4081,4081,4198,4198,4210,4211,4238,4238,4269,4269,4307,4307,4307,4307,4307,4307,4310,4331,4331,4379,4379,4379,4379,4432,4528,4528,4537,4537,4542,4542,4566,4569,4569,4588,4624,4624,4625,4625,4680,4680,4681,4681,4690,4690,4700,4700,4702,4702,4753,4753,4754,4754,4790,4790,4878,4878,4886,4886,4970,4970,4970,4970,5014,5105,5105,5106,5109,5110,5115,5126,5126,5127,5127,5129,5129,5134,5134,5177,5188,5190,5198,5202,5215,5236,5236,5241,5241,5287,5287,5307,5307,5318,5318,5320,5320,5351,5358,5358,5361,5361,5376,5376,5377,5377,5404,5404,5423,5423,5447,5458,5458,5553,5554,5583,5583,5588,5620,5620,5620,5620,5641,5641,5696,5696,5764,5764,5800,5800,5807,5809,5810,5811,5812,5813,5818,5818,5820,5820,5820,5820,5821,5821,5822,5822,5823,5823,5825,5825,5825,5825,5826,5828,5828,5828,5828,5829,5829,5829,5829,5830,5831,5832,5832,5833,5834,5834,5835,5835,5838,5838,5841,5842,5843,5846,5847,5849,5849,5849,5849,5849,5849,5850,5850,5851,5853,5853,5854,5854,5855,5856,5856,5856,5861,5861,5861];
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