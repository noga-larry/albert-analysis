
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

FRAC_TEST = 0.1;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.ID = [4135,4208,4209, 4343,4390, 4569, 4570,4602, 4604, 4605, 4623, 4625, 4658, 4701, 4791, 4806, 4821, 4846, 4886];
req_params.ID = 4208
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;

bin_sz = 50;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(ts)-1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    labels = match_d;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);    
    
    
    for t=1:length(ts)-1
        
        w = (raster_params.time_before + (ts(t):ts(t+1))) +1;
        training_set = raster(w,p);
        training_labels = labels(p);
        test_set = raster(w,:); test_set(:,p)=[];
        test_labels = labels; test_labels(p)=[];
    
        mdl = PsthAsEmClassifierModel;
        mdl = mdl.train(training_set,training_labels);
        accuracy(t,ii) = mdl.evaluate(test_set,test_labels);
    end
    
end

%%
figure;

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    ave = mean(accuracy(:,indType),2);
    sem = nanSEM(accuracy(:,indType,:),2);
    errorbar(ts(1:end-1),ave,sem); hold on
    
end
legend(req_params.cell_type)
sgtitle('Cue','Interpreter', 'none');