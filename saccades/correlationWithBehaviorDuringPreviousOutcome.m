clear

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';
raster_params.time_before = 0;
raster_params.time_after = 700;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)    
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    for p = 1:length(PROBABILITIES)
        
        [r,p_val] = NB_corr_with_prev_outcome(data,raster_params,DIRECTIONS);

        correlation(p,ii) = r;
        significance(p,ii) = p_val<0.05;
    end
    
end

%%
figure; hold on
bins = -1:0.1:1;


for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(squeeze(correlation(p,indType)),bins);
    disp([req_params.cell_type{i} ' - P value: ' num2str(signrank(squeeze(correlation(p,indType))))])
    disp([req_params.cell_type{i} ' - Frac Significant: ' num2str(nanmean(significance(p,indType)))])
    
    
    
    xlabel('NB correlation')
    
end

legend(req_params.cell_type)