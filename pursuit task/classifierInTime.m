
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 200;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

bin_sz = 200;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(ts)-1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1)=1;
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    labels = match_po;
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);     
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    for t=1:length(ts)-1
        
        tb = raster_params.time_before +ts(t)+1;
        te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
        w = tb:te;
        partial_raster = raster(w,:);        
        
        accuracy(t,ii) = trainAndTestClassifier...
            ('PsthDistance',partial_raster,labels,cross_val_sets);        
    end
end

%%
figure;
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    ave = nanmean(accuracy(:,indType),2);
    sem = nanSEM(accuracy(:,indType),2);
    errorbar(ts(1:end-1),ave,sem); hold on
    
end
legend(req_params.cell_type)
xlabel(['Time from ' raster_params.align_to ])
ylabel('Accuracy')


%% Seperated by direction

clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';
raster_params.time_before = 200;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

bin_sz = 200;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(ts)-1,length(cells),length(DIRECTIONS));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1)=1;
    [~,match_d] = getDirections (data);    
    
    for d = 1:length(DIRECTIONS)
        
        ind = find((~boolFail) & match_d==DIRECTIONS(d));
        
        [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
        [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
        match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
        labels = match_o;
        
        raster = getRaster(data,ind,raster_params);
        N = size(raster,2);
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        
        for t=1:length(ts)-1
            
            tb = raster_params.time_before +ts(t)+1;
            te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
            w = tb:te;
            partial_raster = raster(w,:);
            
            accuracy(t,ii,d) = trainAndTestClassifier...
                ('PsthDistance',partial_raster,labels,cross_val_sets);
        end
    end
end

%%

ave_accuracy = squeeze(nanmean(accuracy,3));
figure;
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    ave = nanmean(ave_accuracy(:,indType),2);
    sem = nanSEM(ave_accuracy(:,indType),2);
    errorbar(ts(1:end-1),ave,sem); hold on
    
end
legend(req_params.cell_type)
xlabel(['Time from ' raster_params.align_to ])
ylabel('Accuracy')
yline(0.5)