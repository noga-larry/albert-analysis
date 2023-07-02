clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;
EPOCH = 'cue'; 
BIN_SIZES = [100, 20];

req_params = reqParamsEffectSize("both");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;    
    
    effects(1,ii) = effectSizeInEpoch(data,EPOCH);
    effects(2,ii) = effectSizeInEpoch(data,EPOCH,'binSize',BIN_SIZES(1));
    effects(3,ii) = effectSizeInEpoch(data,EPOCH,'binSize',BIN_SIZES(2));


end

%%

fld = 'reward_probability';
figure;
N = length(req_params.cell_type);

c=1;
for i = 1:length(req_params.cell_type)
    
    subplot(N,2,c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    scatter([effects(1,indType).(fld)],[effects(2,indType).(fld)],'filled','k'); hold on
    [r,p] = corr([effects(1,indType).(fld)]',[effects(2,indType).(fld)]','type','spearman');
    p_positive = bootstrapTTest([effects(2,indType).(fld)])

    title([req_params.cell_type{i} ': r = ' num2str(r) ', p = '  num2str(p)...
        ' ,n = ' num2str(length(indType))])
    xlabel('effect size - 50' )
    ylabel(['effect size - ' num2str(BIN_SIZES(1))])
    
    c=c+1;
    
    subplot(N,2,c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    scatter([effects(1,indType).(fld)],[effects(3,indType).(fld)],'filled','k'); hold on
    [r,p] = corr([effects(1,indType).(fld)]',[effects(3,indType).(fld)]','type','spearman');
    p_positive = bootstrapTTest([effects(3,indType).(fld)])
    title([req_params.cell_type{i} ': r = ' num2str(r) ', p = '  num2str(p)...
        ' ,n = ' num2str(length(indType))])
    xlabel('effect size - 50')
    ylabel(['effect size - ' num2str(BIN_SIZES(2))])
    
    c=c+1;
end


inputOutputFig([effects(2,:).(fld)],cellType); sgtitle([num2str(BIN_SIZES(1))])
inputOutputFig([effects(3,:).(fld)],cellType); sgtitle([num2str(BIN_SIZES(2))])