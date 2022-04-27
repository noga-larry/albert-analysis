%% Comparison in time

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');


req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR', 'BG msn'};
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

epoch = 'targetMovementOnset';

req_params.num_trials = 120;
req_params.task = 'choice';
lines_choice = findLinesInDB (task_info, req_params);

req_params.num_trials = 100;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);

lines = findSameNeuronInTwoLinesLists(task_info,lines_choice,lines_single);

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    both_cells{1} = importdata(cells{1}); both_cells{2} = importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;
    
    for d = 1:length(both_cells)
        
        data = both_cells{d};          
        
        if d==1
            assert(strcmp(data.info.task,'choice'))
        end
       
        
        [eff_time,ts] = effectSizeInTimeBin(data,epoch);
        eff = effectSizeInEpoch(data,epoch);
        
        if strcmp(epoch,'cue') & ~strcmp(data.info.task,'choice')
            eff.direction =NaN;
            eff.interactions =NaN;
            for i=1:length(eff_time)
                eff_time(i).direction =NaN;
                eff_time(i).interactions =NaN;
            end
        end
        
        eff_time = orderfields(eff_time);
        eff = orderfields(eff);
        
        effectSizesInTime(ii,d,:) = eff_time;
        
        [effectSizes(ii,d)] = eff;
       
    end
end

%%

flds = fields(effectSizesInTime);
figure

h = cellID<inf;
tasks = {'choice' 'single target'};

for d = 1:length(tasks)
    
    for f = 1:length(flds)
        
        subplot(length(tasks),length(flds),length(flds)*(d-1)+f); hold on
        
        for i = 1:length(req_params.cell_type)
            
            indType = find(strcmp(req_params.cell_type{i}, cellType) & h);
            
            a = reshape([effectSizesInTime(indType,d,:).(flds{f})],length(indType),length(ts));
            
            errorbar(ts,nanmean(a,1), nanSEM(a,1))
            xlabel(['time from ' epoch ' (ms)' ])
            title(['Task: ' tasks(d) ' - ' flds{f}])
            
        end
        
        legend(req_params.cell_type)
        ylim([-0.05 0.16])
    end
end


%%

flds = fields(effectSizes);
figure

h = cellID<inf;


for f = 1:length(flds)
    
    
    for i = 1:length(req_params.cell_type)
        
        subplot(length(req_params.cell_type),length(flds),length(flds)*(i-1)+f); hold on
        
        indType = find(strcmp(req_params.cell_type{i}, cellType) & h);
        
        scatter([effectSizes(indType,1).(flds{f})],[effectSizes(indType,2).(flds{f})])
        if ~all(isnan([effectSizes(indType,2).(flds{f})]))
            p = signrank([effectSizes(indType,1).(flds{f})],[effectSizes(indType,2).(flds{f})]);
        else
            p=NaN;
        end
        ylabel('single');
        xlabel('choice')
        title(['Type: ' req_params.cell_type{i} ' - ' flds{f} ', p = ' num2str(p)])
        equalAxis()
        refline(1,0)
        
    end
    
    
end
