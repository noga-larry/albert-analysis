
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
    4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
    4791, 4806, 4821, 4846, 4886];
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 1000;
raster_params.smoothing_margins = 0;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(K_FOLD,length(cells));

for ii = 1:length(cells)
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    labels = match_d;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    for k = 1:K_FOLD
        training_set = raster(:,cross_val_sets{k,2});
        training_labels = labels(cross_val_sets{k,2});
        test_set = raster(:,cross_val_sets{k,1});
        test_labels = labels(cross_val_sets{k,1});
        
        mdl = PsthAsEmClassifierModel;
        mdl = mdl.train(training_set,training_labels);
        accuracy(k,ii) = mdl.evaluate(test_set,test_labels);
    end
end

ave_accuracy = mean(accuracy);

%%
figure;

bins = linspace(0,1,50);

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(ave_accuracy(indType),bins); hold on
    
end
legend(req_params.cell_type)
sgtitle(num2str(mean(ave_accuracy)),'Interpreter', 'none');