clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset'; 


req_params = reqParamsEffectSize("pursuit");


lines = findCspkSspkPairs(task_info,req_params);

significance = nan(1,length(lines));

for ii = 1:length(lines)
    cells = findPathsToCells (supPath,task_info,[lines(1,ii),lines(2,ii)]);
       
    dataSspk = importdata(cells{1});
    dataCspk = importdata(cells{2});
    
    cellID(ii) = dataSspk.info.cell_ID;
    
    [dataSspk,dataCspk] = reduceToSharedTrials(dataSspk,dataCspk);
    
    [effects(1,ii)] = effectSizeInEpoch(dataSspk,EPOCH);
    [effects(2,ii),tbl] = effectSizeInEpoch(dataCspk,EPOCH);
    
    switch EPOCH
        case 'cue'
            significance(ii) = tbl{3,end}<0.05;
        case 'targetMovementOnset'
            significance(ii) = tbl{3,end}<0.05;
    end
    
end


%%

figure;

flds = fields(effects);

for j = 1:length(flds)
    subplot(1,length(flds),j); hold on
    scatter([effects(2,:).(flds{j})], [effects(1,:).(flds{j})])
    
    ind = find(significance);
    %scatter([effects(2,ind).(flds{j})], [effects(1,ind).(flds{j})])

    ylabel('Simple')
    xlabel('Complex')
    axis equal
    refline(1,0)
    p = bootstrapTTest([effects(2,:).(flds{j})], [effects(1,:).(flds{j})])
    title([flds{j} ': p = ' num2str(p) ', n = ' num2str(length(lines))])
    
end

sgtitle(EPOCH)

