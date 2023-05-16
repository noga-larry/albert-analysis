
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECIONS = 0:45:315;
PROBABILITIES = [25,75];
PLOT_CELL = false;
TASK = "pursuit";
req_params = reqParamsEffectSize(TASK);
%req_params.cell_type = {'BG msn'};


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

switch EPOCH
    case 'targetMovementOnset'
        fld = 'directions';
end


for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    [~,match_p] = getProbabilities(data);
    boolFail = [data.trials.fail];

    effects(ii) = effectSizeInEpoch(data,EPOCH);

    switch EPOCH

        case 'targetMovementOnset'
            %             for p=1:length(PROBABILITIES)
            %
            %                 inx = find(~boolFail & match_p == PROBABILITIES(p));
            %                 latency(ii,p) = pValLatency(data,inx);
            %
            %             end
            inx = find(~boolFail);

            latency(ii) = pValLatency...
                (data,inx,PLOT_CELL,effects(ii).(fld));


            p = randPermute({data.trials.name});
            for i = 1:length(p)
                data.trials(i).name = p{i};
            end


            latencyControl(ii) = pValLatency...
                (data,inx,PLOT_CELL,effects(ii).(fld));

    end

end

%%
plotLatency(latencyControl,cellType,effects,req_params)
%%

function plotLatency(latency,cellType,effects,req_params)
figure; hold on

fld = 'directions';

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    plotHistForFC([latency(indType)],0:5:800)
    
    leg{i} = [req_params.cell_type{i} ' - frac latency found: ' num2str(mean(~isnan([latency(indType)]),"all"))];
end

legend(leg)
xlabel('Latency')
ylabel('Frac cells')
sgtitle(req_params.task,'Interpreter' ,'none')

[p,tbl,stats] = kruskalwallis(latency(:),cellType(:))
c = multcompare(stats)


figure; hold on

NUM_RANKS = 20;
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    ranks = quantileranks([effects(indType).(fld)],NUM_RANKS);
    unique_ranks = unique(ranks);
    
    for j=1:length(unique_ranks)
        
        inx = indType(find(ranks == j));
        
        ave_effect(j) = mean([effects(inx).(fld)]);
        x=latency(inx);
        
        ave_latency(j) = mean(x(:),'all','omitnan');
        sem_latency(j) = nanSEM(x(:));
        
        n(i,j) = sum(~isnan(x(:)));
        frac_detected(i,j) = mean(~isnan(x(:)));
        %         ave_latency(j) = median(x(:),'all','omitnan');
        %         if ~isnan(ave_latency(j))
        %             ci = bootci(1000,@(x) median(x,'omitnan'),x(:));
        %         else
        %             ci = [nan nan];
        %         end
        %         pos(j) = ci(1); neg(j) = ci(2);
    end
    %errorbar(ave_effect,ave_latency,neg,pos)
    errorbar(ave_effect,ave_latency,sem_latency)
    xlabel(['mean effect size : ' fld],'interpreter','none')
    ylabel('mean latency')
end

sgtitle(req_params.task, 'Interpreter' ,'none')
legend(req_params.cell_type)

end



