
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'choice';
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = false;
req_params.ID = 4000:6000;
req_params.ID = [4081,4081,4198,4198,4210,4211,4238,4238,4269,4269,4307,4307,4307,4307,4307,4307,4310,4331,4331,4379,4379,4379,4379,4432,4528,4528,4537,4537,4542,4542,4566,4569,4569,4588,4624,4624,4625,4625,4680,4680,4681,4681,4690,4690,4700,4700,4702,4702,4753,4753,4754,4754,4790,4790,4878,4878,4886,4886,4970,4970,4970,4970,5014,5105,5105,5106,5109,5110,5115,5126,5126,5127,5127,5129,5129,5134,5134,5177,5188,5190,5198,5202,5215,5236,5236,5241,5241,5287,5287,5307,5307,5318,5318,5320,5320,5351,5358,5358,5361,5361,5376,5376,5377,5377,5404,5404,5423,5423,5447,5458,5458,5553,5554,5583,5583,5588,5620,5620,5620,5620,5641,5641,5696,5696,5764,5764,5800,5800,5807,5809,5810,5811,5812,5813,5818,5818,5820,5820,5820,5820,5821,5821,5822,5822,5823,5823,5825,5825,5825,5825,5826,5828,5828,5828,5828,5829,5829,5829,5829,5830,5831,5832,5832,5833,5834,5834,5835,5835,5838,5838,5841,5842,5843,5846,5847,5849,5849,5849,5849,5849,5849,5850,5850,5851,5853,5853,5854,5854,5855,5856,5856,5856,5861,5861,5861];

raster_params.align_to = 'reward';
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
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    boolFail(1)=1;
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
    match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
    
    labels = match_d(1,:);
    
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

ind = find(cellID>0);
for i = 1:length(req_params.cell_type)
    
    indType = intersect(ind,...
        find(strcmp(req_params.cell_type{i}, cellType)));
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