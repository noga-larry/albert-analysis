
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
load('sessionMap.mat')

CAL_CLASSIFIER = true;
CAL_OMEGA = false;
K_FOLD = 10;
bin_sz = 50;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = true;
req_params.ID = 5000:6000;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(2,length(cells));

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
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1) = true;
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome(data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    boolLick = isTrialWithLick(data,raster_params.align_to, 0, 500, ind);
        
    ind = find(~boolFail);
    frac = mean(~boolLick);
    labels = boolLick;
    
    if frac<0.2 | frac>0.8
        continue
    end
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    if CAL_CLASSIFIER
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        accuracy(1,ii) = trainAndTestClassifier...
            ('PsthDistance',raster,labels,cross_val_sets);
        
        labels = match_p;
        accuracy(2,ii) = trainAndTestClassifier...
            ('PsthDistance',raster,labels,cross_val_sets);
    end
    
    if CAL_OMEGA
        response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
        value = calOmegaSquare(response,{boolLick,match_d});
        omega(1,ii) = value(2).value+value(4).value;
        value = calOmegaSquare(response,{match_o,match_d});
        omega(2,ii) = value(2).value+value(4).value;
    end

end

%%

figure;

effect = accuracy
bins = linspace(0,1,50);
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    subplot(3,2,i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    scatter(effect(1,intersect(ind_relevant,indType)),...
        effect(2,intersect(ind_relevant,indType)))
    refline(1,0)
    p =  signrank(effect(1,intersect(ind_relevant,indType)),...
        effect(2,intersect(ind_relevant,indType)))
    title([req_params.cell_type{i} ', p = ' num2str(p)])
    xlabel('licks')
    ylabel('previous outcome')
    
    nanmean(effect(1,intersect(ind_relevant,indType))-...
        effect(2,intersect(ind_relevant,indType)))
end

%%
figure;

bins = 20;
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(effect(2,intersect(ind_relevant,indType)),bins); hold on
    disp([req_params.cell_type{i} ': ' num2str(signrank(effect(2,intersect(ind_relevant,indType))-0.5))])
end
legend(req_params.cell_type)
xlabel('Accuracy')