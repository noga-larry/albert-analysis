
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4797;

req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;  
    
    [effectSizes(ii,:),ts] = effectSizeInTimeBin...
        (data,raster_params.align_to);
    
    if PLOT_CELL
        
        flds = fields(effectSizes);
        sgtitle([task_info(lines(ii)).cell_type num2str(data.info.cell_ID)])
        for f = 1:length(flds)
            
            subplot(1,length(flds),f); hold on
                        
            plot(ts,[effectSizes(ii,:).(flds{f})])
            xlabel(['time from ' raster_params.align_to ' (ms)' ])
            title(flds{f})
        end
        
        pause
        arrayfun(@cla,findall(0,'type','axes'))

    end
    
end

%%

flds = fields(effectSizes);


h = cellID<inf

figure
for f = 1:length(flds)
    
    subplot(1,length(flds),f); hold on
    
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType) & h');
        
        a = reshape([effectSizes(indType,:).(flds{f})],length(indType),length(ts));
        
        errorbar(ts,nanmean(a,1), nanSEM(a,1))
        xlabel(['time from ' raster_params.align_to ' (ms)' ])
        title(flds{f})
        
    end
    legend(req_params.cell_type)
end

