clear

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';%% if reward than correlation will be calculated with previous trial!!!
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)    
    
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    
    [~,match_p] = getProbabilities (data);

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    for p = 1:length(PROBABILITIES)
        
        ind = find(match_p==PROBABILITIES(p));
        
        if strcmp(raster_params.align_to,'reward')
            [r,p_val] = NB_corr_with_prev_outcome...
                (data,raster_params,DIRECTIONS,ind);
        else
            [r,p_val] = NB_corr(data,raster_params,DIRECTIONS,ind);
        end
        
        correlation(ii,p) = r;
        significance(ii,p) = p_val<0.05;
        
    end
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
        plotHistForFC(squeeze(correlation(indType,p)),bins);
        disp([req_params.cell_type{i} ' - P value: ' ...
            num2str(signrank(squeeze(correlation(indType,p))))])
        disp([req_params.cell_type{i} ' - Frac Significant: ' ...
            num2str(nanmean(significance(indType,p)))])
        
    end
end
legend(req_params.cell_type)
xlabel('NB correlation')
sgtitle(['Aligned to ' raster_params.align_to])


%% Correlation in time
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;
PLOT_CELLS = false;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward'; %% if reward than correlation will be calculated with previous trial!!!
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

times_before = [400:-50:-1000];
times_after = [-200:50:1200];

assert(length(times_before)==length(times_after))

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

correlation = nan(length(cells),length(PROBABILITIES),length(times_before));
significance = nan(length(cells),length(PROBABILITIES),length(times_before));
modulation = nan(length(cells),length(PROBABILITIES));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    [~,match_p] = getProbabilities (data);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    for p = 1:length(PROBABILITIES)
        
        ind = find(~boolFail & match_p==PROBABILITIES(p));
        
        raster_params.time_before = 400;
        raster_params.time_after = 0;
        spks1 = mean(getRaster(data, ind, raster_params));
        
        raster_params.time_before = 0;
        raster_params.time_after = 800;
        spks2 = mean(getRaster(data, ind, raster_params));
        
        modulation(ii,p) = mean(spks1-spks2);        
        
        for t=1:length(times_before)
                        
            ind = find(match_p==PROBABILITIES(p));          
            
            raster_params.time_before = times_before(t);
            raster_params.time_after = times_after(t);
            
            if strcmp(raster_params.align_to,'reward')
                [r,p_val] = NB_corr_with_prev_outcome...
                    (data,raster_params,DIRECTIONS,ind);
            else
                [r,p_val] = NB_corr(data,raster_params,DIRECTIONS,ind);
            end
            correlation(ii,p,t) = r;
            significance(ii,p,t) = p_val<0.05;
        end
    end
    
    if PLOT_CELLS
        
        ind = find(~boolFail & match_p==PROBABILITIES(p));
        raster_params.smoothing_margins = 100;

        for p = 1:length(PROBABILITIES)
            
            raster_params.time_before  = 300;
            raster_params.time_after  = 1200;

            inx = find(~boolFail & match_p==PROBABILITIES(p));        
            psth = getPSTH(data, inx, raster_params); 
            
            ts = -raster_params.time_before:raster_params.time_after;
           
            subplot(2,2,p); 
            title(['Probability = ' num2str(PROBABILITIES(p))])
            plot(ts,psth)
            
            ts = (-times_before+times_after)/2;
            subplot(2,2,2+p); 
            title(['Probability = ' num2str(PROBABILITIES(p))])
            plot(ts,squeeze(correlation(ii,p,:)))
            ylim([-0.4 0.4])

            
        end
        raster_params.smoothing_margins = 0;
        sgtitle([num2str(data.info.cell_ID) ', ' data.info.cell_type])
        pause
    end
end


%%

figure;
ts = (-times_before+times_after)/2;


for p = 1:length(PROBABILITIES)
    
    ind = 1:length(cells);
    
    subplot(2,2,p); hold on
    title(['Probability = ' num2str(PROBABILITIES(p))])
    
    for i = 1:length(req_params.cell_type)
        
        indType = intersect(ind,...
            find(strcmp(req_params.cell_type{i}, cellType)));
        
        ave = squeeze(nanmean(correlation(indType,p,:)));
        sem = squeeze(nanSEM(correlation(indType,p,:)));
        errorbar(ts,ave,sem)
        xlabel(['Time from ' raster_params.align_to])
    end
end

legend(req_params.cell_type)


for p = 1:length(PROBABILITIES)
    
    ind = 1:length(cells);
    
    subplot(2,2,p+2); hold on
    title(['Probability = ' num2str(PROBABILITIES(p))])
    
    for i = 1:length(req_params.cell_type)        
        
        indType = intersect(ind,...
            find(strcmp(req_params.cell_type{i}, cellType)));
        
        ave = squeeze(nanmean(significance(indType,p,:)));
        sem = squeeze(nanSEM(significance(indType,p,:)));
        errorbar(ts,ave,sem)
        xlabel(['Time from ' raster_params.align_to])
        
        yline(0.05)
        
    end
end

sgtitle('All')
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