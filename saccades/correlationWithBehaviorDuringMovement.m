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

raster_params.align_to = 'cue';
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
     
    [r,p_val] = NB_corr(data,raster_params,DIRECTIONS);
    
    correlation(ii) = r;
    significance(ii) = p_val<0.05;
    
    
end

%%
figure; hold on
bins = -1:0.1:1;

for p = 1:length(PROBABILITIES)
    
    disp(['Probability = ' num2str(PROBABILITIES(p)) ':'])
    subplot(2,1,p); hold on
    title(['Probability = ' num2str(PROBABILITIES(p))])
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        plotHistForFC(squeeze(correlation(p,indType)),bins);
        disp([req_params.cell_type{i} ' - P value: ' num2str(signrank(squeeze(correlation(p,indType))))])
        disp([req_params.cell_type{i} ' - Frac Significant: ' num2str(nanmean(significance(p,indType)))])
        
    end
end
legend(req_params.cell_type)
xlabel('NB correlation')

%% Correlation in time
[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;
BIN_SIZE = 200;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

times_before = [800:-50:-1000];
times_after = [-600:50:1200];

assert(length(times_before)==length(times_after))

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

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
        
        [r,p_val] = NB_corr(data,raster_params,DIRECTIONS);
        
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
    xlabel(['Time from ' raster_params.align_to])
end


legend(req_params.cell_type)

subplot(2,1,2); hold on
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    ave = squeeze(nanmean(significance(indType,:)));
    sem = squeeze(nanSEM(significance(indType,:)));
    errorbar(ts,ave,sem)
    xlabel(['Time from ' raster_params.align_to])
    
    yline(0.05)
    
end

%%

figure
indType = find(strcmp('CRB', cellType));
indTime1 = find(ts==100);
indTime2 = find(ts==300);

for p = 1:length(PROBABILITIES)
    subplot(1,2,p)
    comp1 = squeeze(correlation(p,indType,indTime1));
    comp2 = squeeze(correlation(p,indType,indTime2));
    
    scatter(comp1', comp2')
    
    [r,p_val] = corr(comp1(1,:)', comp2(1,:)')
    title(['Probability = ', num2str(PROBABILITIES(p)),...
        ': r = ' num2str(r), ', p = ', num2str(p_val) ])
    equalAxis()
    xlabel('100 ms')
    ylabel('300 ms')
end

sgtitle('CRB')



%% Correlation in time PD versus Null
clear 

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
BIN_SIZE = 200;
ANGLES_AROUND = [0];

comparison_window = [100:400];

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

times_before = [800:-50:-1000];
times_after = [-600:50:1200];

assert(length(times_before)==length(times_after))

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

modulation = nan(1,length(cells));
correlation = nan(2,length(cells),length(times_before));
significance = nan(2,length(cells),length(times_before));


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    raster_params.time_before = 400;
    raster_params.time_after = -100;
    
    boolFail = [data.trials.fail];
    [~,match_d] = getDirections (data);
    
    PD = getPD(data,1:length(data.trials),comparison_window);
    for d = 1:2 %PD and Null
        
        if d==1
            cur_dir = mod(PD,360);
        elseif d==2
            cur_dir = mod(PD+180,360);
        end
        
        inx = find(~boolFail & match_d == cur_dir);
        
        baseline = mean(getRaster(data, inx, raster_params))*1000;
        
        raster_params.time_before = -100;
        raster_params.time_after = 400;
        
        response = mean(getRaster(data, find(~boolFail), raster_params))*1000;
        
        modulation(d,ii) = mean(response)- mean(baseline);        
    
        
        for t=1:length(times_before)
            raster_params.time_before = times_before(t);
            raster_params.time_after = times_after(t);
            
            [r,p_val] = NB_corr(data,raster_params,mod(cur_dir+ANGLES_AROUND,360));
            
            correlation(d,ii,t) = r;
            significance(d,ii,t) = p_val<0.05;
        end
    end
end


%%
ts = (-times_before+times_after)/2;
figure;
c=0;

cell_groups_names = {'Deceasing','Incresing'};

dirs = {'PD','Null'};
for d = 1:2 %PD and Null
    for j = 1:2
        if j==1
            cell_group = find(modulation(d,:)<0);
        elseif j==2
            cell_group = find(modulation(d,:)>0);
        end
        c = c+1;
        subplot(2,2,c); hold on
        title([cell_groups_names{j} ', ' dirs{d}])
        for i = 1:length(req_params.cell_type)
            
            indType = intersect(find(strcmp(req_params.cell_type{i}, cellType)),...
                cell_group);
            
            ave = squeeze(nanmean(correlation(d,indType,:),2));
            sem = squeeze(nanSEM(correlation(d,indType,:),2));
            errorbar(ts,ave,sem)
            xlabel(['Time from ' raster_params.align_to])
        end
    end
end
legend(req_params.cell_type)