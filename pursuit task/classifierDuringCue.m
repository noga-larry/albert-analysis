
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
load('sessionMap.mat')

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.num_trials = 30;
req_params.remove_question_marks = 0;
req_params.remove_repeats = true;
req_params.ID = 5000:6000;

raster_params.align_to = 'reward';
raster_params.time_before = 0;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(cells));


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    if ismember(cellType{ii},{'PC ss','PC cs','CRB'})
        session_list = sessionMap('Vermis');
    else
        session_list = sessionMap('BG');
    end
    
    bool_sig_session(ii) = ismember(data.info.session,session_list);
    
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome(data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
  accuracy(ii) = trainAndTestClassifier...
    ('PsthDistance',raster,labels,cross_val_sets)
end

ave_accuracy = mean(accuracy);
%%
figure;

bins = linspace(0,1,50);
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(ave_accuracy(intersect(ind_relevant,indType)),bins); hold on
    disp([req_params.cell_type{i} ': ' num2str(mean(bool_sig_session(indType)))])
end
legend(req_params.cell_type)
sgtitle(num2str(nanmean(ave_accuracy)),'Interpreter', 'none');
xlabel('Accuracy')