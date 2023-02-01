clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;
EPOCH = 'cue'; 

req_params = reqParamsEffectSize("both");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;    
    
    effects(1,ii) = effectSizeInEpoch(data,EPOCH);
    effects(2,ii) = effectSizeInEpoch(data,EPOCH,'binSize',100);
    effects(3,ii) = effectSizeInEpoch(data,EPOCH,'binSize',20);


end

%%


figure;
N = length(req_params.cell_type);

c=1;
for i = 1:length(req_params.cell_type)
    
    subplot(N,2,c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    scatter([effects(1,indType).reward],[effects(2,indType).reward],'filled','k'); hold on
    [r,p] = corr([effects(1,indType).reward]',[effects(2,indType).reward]','type','spearman');
    title([req_params.cell_type{i} ': r = ' num2str(r) ', p = '  num2str(p)...
        ' ,n = ' num2str(length(indType))])
    xlabel('effect size - 50')
    ylabel('effect size - 100')
    
    c=c+1;
    
    subplot(N,2,c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    scatter([effects(1,indType).reward],[effects(3,indType).reward],'filled','k'); hold on
    [r,p] = corr([effects(1,indType).reward]',[effects(3,indType).reward]','type','spearman');
    title([req_params.cell_type{i} ': r = ' num2str(r) ', p = '  num2str(p)...
        ' ,n = ' num2str(length(indType))])
    xlabel('effect size - 50')
    ylabel('effect size - 20')
    
    c=c+1;
end


inputOutputFig([effects(3,:).reward],cellType); sgtitle('20 ms')
inputOutputFig([effects(2,:).reward],cellType); sgtitle('100 ms')