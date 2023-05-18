
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECIONS = 0:45:315;
PROBABILITIES = [25,75];
PLOT_CELL = false;
TASK = "saccade";
req_params = reqParamsEffectSize(TASK);
%req_params.cell_type = {'BG msn'};

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

switch EPOCH
    case {'targetMovementOnset','saccadeLatency'}
        latency = nan(length(cells),length(DIRECIONS));
end


for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    boolFail = [data.trials.fail];
    [~,match_d] = getDirections(data);
    [~,match_p] = getProbabilities(data);

    switch EPOCH

        case 'targetMovementOnset'
                for d=1:length(DIRECIONS)
                    inx{d} = find(match_d==DIRECIONS(d) & ~boolFail);
                end
                
                for j=1:length(inx)
                    latency(ii,j) = rateChange(data,inx,j,EPOCH,PLOT_CELL);
                    latencyControl(ii,j) = rateChangeControl(data,inx,j,EPOCH,PLOT_CELL);              
                end
            
            
        case {'saccadeLatency'}
            data = getBehavior (data,supPath);
            for p=1:length(PROBABILITIES)
                for d=1:length(DIRECIONS)
                    inx{d} = find(match_p==PROBABILITIES(p) & ...
                        match_d==DIRECIONS(d) & ~boolFail);
                end
                for j=1:length(inx)
                    latency(ii,p,j) = rateChange(data,inx,j,EPOCH,PLOT_CELL);
                end
            end
            
        otherwise
            error('No case!')

    end

    effects(ii) = effectSizeInEpoch(data,EPOCH);




end


%%
plotLatency(latency,cellType,effects,req_params)
%%

function plotLatency(latency,cellType,effects,req_params)

figure; hold on

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    plotHistForFC([latency(indType,:,:)],0:5:800)
    
    leg{i} = [req_params.cell_type{i} ' - frac latency found: ' num2str(mean(~isnan([latency(indType,:)]),"all"))];
end

legend(leg)
xlabel('Latency')
ylabel('Frac cells')
sgtitle(req_params.task,'Interpreter' ,'none')

% test
groups = repmat(cellType,[1 size(latency,[2,3])]);

[p,tbl,stats] = kruskalwallis(latency(:),groups(:))
c = multcompare(stats)

figure; hold on

fld = 'time_and_interactions_with_time';
fld = 'directions';

relEffectSize = [effects.(fld)];
NUM_RANKS = 20;


for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    ranks = quantileranks(relEffectSize(indType),NUM_RANKS);
    unique_ranks = unique(ranks);
    
    for j=1:length(unique_ranks)
        
        inx = indType(find(ranks == j));
        
        ave_effect(j) = mean([effects(inx).(fld)]);
        x=latency(inx,:,:);
        
        ave_latency(j) = mean(x(:),'all','omitnan');
        sem_latency(j) = nanSEM(x(:));
        %         ave_latency(j) = median(x(:),'all','omitnan');
        %         if ~isnan(ave_latency(j))
        %             ci = bootci(1000,@(x) median(x,'omitnan'),x(:));
        %         else
        %             ci = [nan nan];
        %         end
        %         pos(j) = ci(1); neg(j) = ci(2);
        
        n(i,j) = sum(~isnan(x(:)));
    end
    %errorbar(ave_effect,ave_latency,neg,pos)
    errorbar(ave_effect,ave_latency,sem_latency)
    xlabel(['mean effect size : ' fld],'interpreter','none')
    ylabel('mean latency')
end

sgtitle(req_params.task,'Interpreter' ,'none')
legend(req_params.cell_type)
end



