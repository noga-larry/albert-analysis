clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");

req_params.task = 'saccade_8_dir_75and25';
lines_sacc = findLinesInDB (task_info, req_params);

req_params.task = 'pursuit_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);

EPOCH = 'targetMovementOnset';

lines = findSameNeuronInTwoLinesLists(task_info,lines_sacc,lines_single);

omegaR = nan(2,length(lines));
omegaD = nan(2,length(lines));
for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    both_cells{1} = importdata(cells{1}); both_cells{2} = importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;
    
    for j=1:length(both_cells)
        
        effects(j,ii) = effectSizeInEpoch(both_cells{j},EPOCH);
        
    end
end


%%

N = length(req_params.cell_type);
figure;

h = cellID>-inf;

flds = fields(effects);
for j=1:length(flds)
    
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType) & h);
        
        subplot(length(flds),N,N*(j-1)+i)
        scatter([effects(1,indType).(flds{j})],[effects(2,indType).(flds{j})],'filled','k'); hold on
        p1 = signrank([effects(1,indType).(flds{j})],[effects(2,indType).(flds{j})]);
        [r,p2] = corr([effects(1,indType).(flds{j})]',[effects(2,indType).(flds{j})]','type','Spearman');
        xlabel('saccade')
        ylabel('pursuit')
        equalAxis()
        refline(1,0)
        title([flds{j} ' ' req_params.cell_type{i}],'Interpreter' ,'none')
        subtitle(['signkrank: p = ' num2str(p1) ' | corr: r = ' num2str(r) ...
            ', p = ' num2str(p2), ', n = ' num2str(length(indType))])

        
    end
end