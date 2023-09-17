clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
%load('sessionMap.mat')

K_FOLD = 10;
EPOCH = 'targetMovementOnset';

req_params = reqParamsEffectSize("saccade");

raster_params.align_to = EPOCH;
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
%     if ismember(cellType{ii},{'PC ss','PC cs','CRB'})
%         session_list = sessionMap('Vermis');
%     else
%         session_list = sessionMap('BG');
%     end
    
%    bool_sig_session(ii) = ismember(data.info.session,session_list);
    
    boolFail = [data.trials.fail];% | ~[data.trials.previous_completed];
    %boolFail(1)=1;
    ind = find(~boolFail);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);

    labels = match_d;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);
    
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    PD = getPD(data,1:length(data.trials),0:800);
    accuracy(ii) = trainAndTestClassifier...
        ('PsthDistanceFromPD',raster,labels,cross_val_sets,PD);
    
    effects(ii) = effectSizeInEpoch(data,EPOCH);

end



%% accuracy and effect size

figure;

N = length(req_params.cell_type);

fld = 'directions';

for i = 1:length(req_params.cell_type)
    subplot(2,ceil(N/2),i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    scatter([effects(indType).(fld)],accuracy(indType));
    [r,p] = corr([effects(indType).(fld)]',accuracy(indType)','type','spearman');
    title([req_params.cell_type{i} ': r = ' num2str(r) ', p = '  num2str(p)...
        ' ,n = ' num2str(length(indType))])
    ylabel('Accuracy')
    xlabel('effect size')
    
end

inputOutputFig(accuracy,cellType)

p = bootstraspWelchANOVA(accuracy', cellType')

p = bootstraspWelchTTest(accuracy(find(strcmp('SNR', cellType))),...
    accuracy(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(accuracy(find(strcmp('SNR', cellType))),...
    accuracy(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(accuracy(find(strcmp('SNR', cellType))),...
    accuracy(find(strcmp('BG msn', cellType))))
