
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
    case 'targetMovementOnset'
        fld = 'directions';
end


for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [~,match_p] = getProbabilities(data);
    boolFail = [data.trials.fail];
    
    switch EPOCH
        
        case 'targetMovementOnset'
            %             for p=1:length(PROBABILITIES)
            %
            %                 inx = find(~boolFail & match_p == PROBABILITIES(p));
            %                 latency(ii,p) = pValLatency(data,inx);
            %
            %             end
            inx = find(~boolFail);
            latency(ii) = pValLatency(data,inx);
    end
    
    effects(ii) = effectSizeInEpoch(data,EPOCH);
    
end

%%

figure; hold on

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    plotHistForFC([latency(indType)],0:5:800)

    leg{i} = [req_params.cell_type{i} ' - frac latency found: ' num2str(mean(~isnan([latency(indType,:)]),"all"))];
end

legend(leg)
xlabel('Latency')
ylabel('Frac cells')
sgtitle(TASK)

figure; hold on

fld = 'time_and_interactions_with_time';
fld = 'directions';
ranks = quantileranks([effects.(fld)],10);

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    for j=1:length(ranks)
        
        inx = intersect(indType,  find(ranks == j));

        ave_effect(j) = mean([effects(inx).(fld)]);
        x=latency(inx,:);

        ave_latency(j) = mean(x(:),'all','omitnan');
        sem_latency(j) = nanSEM(x(:));
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

sgtitle(TASK)
legend(req_params.cell_type)


%%

function lat = pValLatency(data,inx)

FIRST_RUNNING_WINDOW = -50:50;
SECOND_RUNNING_WINDOW = -25:25;
TIME_BEFORE = 100;
TIME_AFTER = 800;
DIRECTIONS = 0:45:315;
FIRST_INTERVALS = 5;
SECOND_INTERVALS = 3;
NUM_CONSECUTIVE = 4;

ts = -TIME_BEFORE:FIRST_INTERVALS:TIME_AFTER;
consecutive_counter = 0;

for t=1:length(ts)
    comparison_window = ts(t)+FIRST_RUNNING_WINDOW;
    [~,~,h] = getTC(data, DIRECTIONS, inx, comparison_window);
    if h
        consecutive_counter = consecutive_counter+1;
    else
        consecutive_counter=0;
    end
    
    if consecutive_counter==NUM_CONSECUTIVE
        break
    end
end

if consecutive_counter~=NUM_CONSECUTIVE
    lat=nan;
    return
end

first_localization_estimate = ts(max(1,t-NUM_CONSECUTIVE)):SECOND_INTERVALS:ts(t);

consecutive_counter = 0;
for t=1:length(first_localization_estimate)
    comparison_window = first_localization_estimate(t)+SECOND_RUNNING_WINDOW;
    [~,~,h(t)] = getTC(data, DIRECTIONS, inx, comparison_window);
    if h(t)
        consecutive_counter = consecutive_counter+1;
    else
        consecutive_counter=0;
    end
    
    if consecutive_counter==NUM_CONSECUTIVE
        break
    end
end

if consecutive_counter~=NUM_CONSECUTIVE
    lat=nan;
    return
end

lat = first_localization_estimate(t-ceil(NUM_CONSECUTIVE/2));

end
