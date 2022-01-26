%% list of cell IDs

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

req_params.num_trials = 50;
req_params.task = 'choice';
lines_choice = findLinesInDB (task_info, req_params);

req_params.num_trials = 100;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);

lines = findSameNeuronInTwoLinesLists(task_info,lines_choice,lines_single)

ID_sample = [lines.cell_ID];



K_FOLD = 10;

req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.num_trials = 100;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));
label_for_perumation_test = nan(1,length(cells));


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    assert(strcmp(task_info(lines(ii)).cell_type,req_params.cell_type))
    
    boolFail = [data.trials.fail];% | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
   
    labels = match_d;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    accuracy(ii) = trainAndTestClassifier...
        ('PsthDistance',raster,labels,cross_val_sets);
    
    label_for_perumation_test(ii) = ...
        ismember(data.info.cell_ID,ID_sample); 
end

%%

bins = linspace(0,1,50);

p_val = permutationTest(accuracy,label_for_perumation_test,...
    10000,@mean,1)

figure; hold on
plotHistForFC(accuracy(find(label_for_perumation_test)),bins); hold on
plotHistForFC(accuracy(find(~label_for_perumation_test)),bins); hold on

legend('choice','rest')