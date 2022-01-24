
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'choice';
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.ID = 4000:6000;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 300;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    cellType{ii} =task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
        
    boolFail = [data.trials.fail] | ~[data.trials.choice] | ~[data.trials.previous_completed];
    boolFail(1)=1;
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome(data,ind,'omitNonIndexed',true);
    [match_po] = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    
    labels = match_p(1,:)-match_p(2,:);
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    accuracy(ii) = trainAndTestClassifier...
    ('PsthDistance',raster,labels,cross_val_sets);
end


%%
f = figure;

chance_level = 1/length(unique(labels));

bins = linspace(0,1,50);
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(accuracy(indType),bins); hold on
    p = signrank(accuracy(indType)-chance_level);
    disp([req_params.cell_type{i} ': ' num2str(p)])
end
legend(req_params.cell_type)
xlabel('Accuracy')

p = kruskalwallis(accuracy,cellType);

sgtitle(f,['kruskal wallis: p = ' num2str(p)])