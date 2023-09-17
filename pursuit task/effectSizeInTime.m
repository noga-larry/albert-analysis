
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'cue';
PLOT_CELL = false;
ONLY_TIME_SIG = false;

req_params = reqParamsEffectSize("pursuit");
%req_params.cell_type = {'PC cs'};
%req_params.ID =  5666;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});

    %data = getBehavior (data,supPath);

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;  
    
    if ONLY_TIME_SIG
       [~, ~,~,~,pVals] = effectSizeInEpoch(data,EPOCH);
       rel(ii) = pVals.time<0.05;
    end
    
    [effectSizes(ii,:),ts] = effectSizeInTimeBin...
        (data,EPOCH,'prevOut',false,...
        'velocityInsteadReward',false);
    
    if PLOT_CELL
        
        flds = fields(effectSizes);
        sgtitle([task_info(lines(ii)).cell_type num2str(data.info.cell_ID)...
            '- ' data.info.task],...
             'interpreter','none')
        for f = 1:length(flds)
            
            subplot(1,length(flds),f); hold on
                        
            plot(ts,[effectSizes(ii,:).(flds{f})])
            xlabel(['time from ' EPOCH ' (ms)' ])
            title(flds{f}, 'interpreter','none')
        end
        
        pause
        arrayfun(@cla,findall(0,'type','axes'))

    end
    
end

%%

flds = fields(effectSizes);


%h = rel';

figure
for f = 1:length(flds)
    
    subplot(1,length(flds),f); hold on
    
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        
       a = reshape([effectSizes(indType,:).(flds{f})],length(indType),length(ts));
        
        errorbar(ts,nanmean(a,1), nanSEM(a,1))
        xlabel(['time from ' EPOCH ' (ms)' ])
        title(flds{f}, 'Interpreter', 'none')

        disp([req_params.cell_type{i} ': n = ' num2str(length(indType))...
            '/ ' num2str(sum(strcmp(req_params.cell_type{i}, cellType))) ...
            '   - ' num2str(length(indType)...
            /sum(strcmp(req_params.cell_type{i}, cellType)))])
        
    end
    legend(req_params.cell_type)
end

%%

