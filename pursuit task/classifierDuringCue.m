
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
load('sessionMap.mat')

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
%req_params.ID = [4081,4081,4198,4198,4210,4211,4238,4238,4269,4269,4307,4307,4307,4307,4307,4307,4310,4331,4331,4379,4379,4379,4379,4432,4528,4528,4537,4537,4542,4542,4566,4569,4569,4588,4624,4624,4625,4625,4680,4680,4681,4681,4690,4690,4700,4700,4702,4702,4753,4753,4754,4754,4790,4790,4878,4878,4886,4886,4970,4970,4970,4970,5014,5105,5105,5106,5109,5110,5115,5126,5126,5127,5127,5129,5129,5134,5134,5177,5188,5190,5198,5202,5215,5236,5236,5241,5241,5287,5287,5307,5307,5318,5318,5320,5320,5351,5358,5358,5361,5361,5376,5376,5377,5377,5404,5404,5423,5423,5447,5458,5458,5553,5554,5583,5583,5588,5620,5620,5620,5620,5641,5641,5696,5696,5764,5764,5800,5800,5807,5809,5810,5811,5812,5813,5818,5818,5820,5820,5820,5820,5821,5821,5822,5822,5823,5823,5825,5825,5825,5825,5826,5828,5828,5828,5828,5829,5829,5829,5829,5830,5831,5832,5832,5833,5834,5834,5835,5835,5838,5838,5841,5842,5843,5846,5847,5849,5849,5849,5849,5849,5849,5850,5850,5851,5853,5853,5854,5854,5855,5856,5856,5856,5861,5861,5861];
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));


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
    
    boolFail = [data.trials.fail];% | ~[data.trials.previous_completed];
    %boolFail(1)=1;
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    match_o = getOutcome(data,ind,'omitNonIndexed',true);
    
    labels = match_d;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    accuracy(ii) = trainAndTestClassifier...
        ('PsthDistance',raster,labels,cross_val_sets);
end

%%
figure;

bins = linspace(0,1,50);
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(accuracy(intersect(ind_relevant,indType)),bins); hold on
    p = signrank(accuracy(intersect(ind_relevant,indType))-(1/8));
    disp([req_params.cell_type{i} ': ' num2str(p)])
end
legend(req_params.cell_type)
sgtitle(num2str(nanmean(accuracy)),'Interpreter', 'none');
xlabel('Accuracy')

kruskalwallis(accuracy,cellType)

%% Seperated by direction
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
load('sessionMap.mat')

K_FOLD = 10;
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = true;
req_params.ID = 4000:6000;

raster_params.align_to = 'reward';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 300;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(cells),length(DIRECTIONS));


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
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1)=1;
    [~,match_d] = getDirections (data);
    
    for d = 1:length(DIRECTIONS)
        
        ind = find((~boolFail) & match_d==DIRECTIONS(d));
        
        [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);        
        match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
        match_o = getOutcome(data,ind,'omitNonIndexed',true);
        
        labels = match_o;
        
        raster = getRaster(data,ind,raster_params);
        N = size(raster,2);
        
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        
        accuracy(ii,d) = trainAndTestClassifier...
            ('PsthDistance',raster,labels,cross_val_sets);
    end
end

%%
figure;

ave_accuracy = nanmean(accuracy,2);
bins = linspace(0,1,50);
ind_relevant = 1:length(cells);
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(ave_accuracy(intersect(ind_relevant,indType)),bins); hold on
    p = signrank(ave_accuracy(intersect(ind_relevant,indType))-(1/8));
    disp([req_params.cell_type{i} ': ' num2str(p)])
end
legend(req_params.cell_type)
sgtitle(num2str(nanmean(ave_accuracy)),'Interpreter', 'none');
xlabel('Accuracy')