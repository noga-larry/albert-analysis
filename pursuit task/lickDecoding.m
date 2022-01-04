
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
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = true;
req_params.ID = 4000:5000;

raster_params.align_to = 'reward';
raster_params.time_before = 0;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(K_FOLD,2,length(cells));

lines = findLinesInDB(task_info,req_params);
lickInd = cellfun(@(c) ~isempty(c) && c==1,{task_info(lines).lick},'uni',false);
lickInd = [lickInd{:}];
lickInd = find(lickInd);
lines = lines(lickInd);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getLicking(data,MaestroPath);
    
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
    boolLick = isTrialWithLick(data,raster_params.align_to, 0, 500);
        
    ind = find(~boolFail);
    frac = mean(~boolLick(ind));
    labels = boolLick;
    
    if frac<0.2 | frac>0.8
        continue
    end
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    for k = 1:K_FOLD
        training_set = raster(:,cross_val_sets{k,2});
        training_labels = labels(cross_val_sets{k,2});
        test_set = raster(:,cross_val_sets{k,1});
        test_labels = labels(cross_val_sets{k,1});
        
        mdl = PsthDistanceClassifierModel;
        mdl = mdl.train(training_set,training_labels);
        accuracy(k,1,ii) = mdl.evaluate(test_set,test_labels);
    end
    
    labels = match_o;
    
    for k = 1:K_FOLD
        training_set = raster(:,cross_val_sets{k,2});
        training_labels = labels(cross_val_sets{k,2});
        test_set = raster(:,cross_val_sets{k,1});
        test_labels = labels(cross_val_sets{k,1});
        
        mdl = PsthDistanceClassifierModel;
        mdl = mdl.train(training_set,training_labels);
        accuracy(k,2,ii) = mdl.evaluate(test_set,test_labels);
    end
end

ave_accuracy = squeeze(mean(accuracy));
%%
figure;

bins = linspace(0,1,50);
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    subplot(3,2,i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    scatter(ave_accuracy(1,intersect(ind_relevant,indType)),...
        ave_accuracy(2,intersect(ind_relevant,indType)))
    refline(1,0)
    p =  signrank(ave_accuracy(1,intersect(ind_relevant,indType)),...
        ave_accuracy(2,intersect(ind_relevant,indType)))
    title([req_params.cell_type{i} ', p = ' num2str(p)])
    xlabel('licks')
    ylabel('reward')
end
