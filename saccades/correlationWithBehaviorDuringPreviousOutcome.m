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
raster_params.time_after = 1200;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)    
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
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
x = nan(1,length(cellType));

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(squeeze(correlation(p,indType)),bins,'unNormalized');
    disp([req_params.cell_type{i} ' - P value: ' num2str(signrank(squeeze(correlation(p,indType))))])
    disp([req_params.cell_type{i} ' - Frac Significant: ' num2str(nanmean(significance(p,indType)))])
    
    xlabel('NB correlation')
    
end

kruskalwallis(correlation(p,:),cellType)
legend(req_params.cell_type)


%%

clear

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;

times_before = [800:-50:-1500];
times_after = [-600:50:1700];

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

assert(length(times_before)==length(times_after))

correlation = nan(length(cells),length(times_before));
significance = nan(length(cells),length(times_before));

for ii = 1:length(cells)    
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;  
    
    for t=1:length(times_before)
        
        raster_params.time_before = times_before(t);
        raster_params.time_after = times_after(t);
        
        [r,p_val] = NB_corr_with_prev_outcome(data,raster_params,DIRECTIONS);
        
        correlation(ii,t) = r;
        significance(ii,t) = p_val<0.05;
        
    end
end

%%

ts = (-times_before+times_after)/2;

figure;

subplot(2,1,1); hold on
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    ave = squeeze(nanmean(correlation(indType,:)));
    sem = squeeze(nanSEM(correlation(indType,:)));
    errorbar(ts,ave,sem)
    
end
ylabel('Correlation')
xlabel(['Time from ' raster_params.align_to])

legend(req_params.cell_type)


subplot(2,1,2); hold on
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    ave = squeeze(nanmean(significance(indType,:)));
    sem = squeeze(nanSEM(significance(indType,:)));
    errorbar(ts,ave,sem)
    
end
ylabel('Significance')
xlabel(['Time from ' raster_params.align_to])
yline(0.05)
