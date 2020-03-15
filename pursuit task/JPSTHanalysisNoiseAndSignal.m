clear all
load ('C:\noga\TD complex spike analysis\task_info');
tasks = {'saccade_8_dir_75and25','pursuit_8_dir_75and25'}
req_params.grade = 7;
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;

cell_type1 = 'CRB|PC ss';
cell_type2 = 'CRB|PC ss';
pairs = [];
counter = 0;

for t = 1:length(tasks)
    req_params.task = tasks{t};
    req_params.cell_type = cell_type1;
    lines1 = findLinesInDB (task_info, req_params);
    req_params.cell_type = cell_type2;
    lines2 = findLinesInDB (task_info, req_params);
    for ii=1:length(lines1)
        simLines = task_info(lines1(ii)).cell_recorded_simultaneously;
        simLines = intersect(lines2,simLines);
        for jj = 1:length(simLines)
            counter = counter +1;
            pairs(counter).task = tasks{t};
            pairs(counter).cell1 = lines1(ii);
            pairs(counter).cell2 = simLines(jj);


        end
        
    end
end


for ii=1:length(pairs)
    cellIDs(1,ii) = min([task_info(pairs(ii).cell1).cell_ID,...
        task_info(pairs(ii).cell2).cell_ID]);
    cellIDs(2,ii) = max([task_info(pairs(ii).cell1).cell_ID,...
        task_info(pairs(ii).cell2).cell_ID]);
       
end

[~,ind,~] = unique(cellIDs','rows');
pairs = pairs(ind);

%% 
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 5;
raster_params.plot_cell = 1;

comparison_window = raster_params.time_before +[100:300];

for ii = 1:length(pairs)
    
    cells = findPathsToCells ([supPath pairs(ii).task ],task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    
    sharedTrials = intersect({data1.trials.maestro_name},...
        {data2.trials.maestro_name});
    
    Match = cellfun(@(x) ismember(x, sharedTrials), {data1.trials.maestro_name}, 'UniformOutput', 0);
    data1.trials = data1.trials(find(cell2mat(Match)));
    Match = cellfun(@(x) ismember(x, sharedTrials), {data2.trials.maestro_name}, 'UniformOutput', 0);
    data2.trials = data2.trials(find(cell2mat(Match)));
    
    assert(length(data1.trials)==length(data2.trials))
   
    boolFail = [data1.trials.fail];
    [~,match_p] = getProbabilities (data1);
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow1 = getRaster(data1,indLow,raster_params);
    rasterHigh1 = getRaster(data1,indHigh,raster_params);
    rasterLow2 = getRaster(data2,indLow,raster_params);
    rasterHigh2 = getRaster(data2,indHigh,raster_params);
    
    TC1(1) = mean(mean(rasterLow1(comparison_window,:)));
    TC2(1) = mean(mean(rasterLow2(comparison_window,:)));
    TC1(2) = mean(mean(rasterHigh1(comparison_window,:)));
    TC2(2) = mean(mean(rasterHigh2(comparison_window,:)));
    
    signalCorr(ii) = corr(TC1',TC2');
    

    indSets{1} = find ((~boolFail) & match_p == 75);
    indSets{2} = find ((~boolFail) & match_p == 25);
    
    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
    
   % pause
end


figure;
ind = find(signalCorr>0);
subplot(2,2,1)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

ind = find(signalCorr<0);
subplot(2,2,3)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,4)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

suptitle ([data1.info.cell_type '\' data1.info.cell_type ])

%% movement

supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 5;
raster_params.plot_cell = 1;

directions = 0:45:315;
comparison_window = 100:300;

for ii = 1:length(pairs)
    
    cells = findPathsToCells ([supPath pairs(ii).task ],task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    
    sharedTrials = intersect({data1.trials.maestro_name},...
        {data2.trials.maestro_name});
    
    Match = cellfun(@(x) ismember(x, sharedTrials), {data1.trials.maestro_name}, 'UniformOutput', 0);
    data1.trials = data1.trials(find(cell2mat(Match)));
    Match = cellfun(@(x) ismember(x, sharedTrials), {data2.trials.maestro_name}, 'UniformOutput', 0);
    data2.trials = data2.trials(find(cell2mat(Match)));
    
    assert(length(data1.trials)==length(data2.trials))
   
    boolFail = [data1.trials.fail];
    [~,match_p] = getProbabilities (data1);
    [~,match_d] = getDirections (data1);

    
    for d = 1:length(directions)
    indSets{2*(d-1)+2} = find ((~boolFail) & match_p == 75 & match_d == directions(d));
    indSets{2*(d-1)+1} = find ((~boolFail) & match_p == 25 & match_d == directions(d));
    end

    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
    
    [TC1,~,~] = getTC(data1, directions,1:length(data1.trials), comparison_window);
    [TC2,~,~] = getTC(data2, directions,1:length(data2.trials), comparison_window);
        
    signalCorr(ii) = corr(TC1,TC2);

    %pause
end


figure;
ind = find(signalCorr>0);
subplot(2,2,1)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

ind = find(signalCorr<0);
subplot(2,2,3)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,4)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

suptitle ([data1.info.cell_type '\' data1.info.cell_type ])


%% reward


supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'reward';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 5;
raster_params.plot_cell = 1;

comparison_window = raster_params.time_before +[100:300];


for ii = 1:length(pairs)
    
    cells = findPathsToCells ([supPath pairs(ii).task ],task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    
    sharedTrials = intersect({data1.trials.maestro_name},...
        {data2.trials.maestro_name});
    
    Match = cellfun(@(x) ismember(x, sharedTrials), {data1.trials.maestro_name}, 'UniformOutput', 0);
    data1.trials = data1.trials(find(cell2mat(Match)));
    Match = cellfun(@(x) ismember(x, sharedTrials), {data2.trials.maestro_name}, 'UniformOutput', 0);
    data2.trials = data2.trials(find(cell2mat(Match)));
    
    assert(length(data1.trials)==length(data2.trials))
   
    boolFail = [data1.trials.fail];
    [~,match_p] = getProbabilities (data1);
    [match_o] = getOutcome(data1);
    
    indSets{1} = find ((~boolFail) & match_p == 25 & match_o == 1);
    indSets{2} = find ((~boolFail) & match_p == 25 & match_o == 0);
    indSets{3} = find ((~boolFail) & match_p == 75 & match_o == 1);
    indSets{4} = find ((~boolFail) & match_p == 75 & match_o == 0);
    
    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
        
    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indLowNR = find (match_p == 25 & (~match_o) & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    indHighNR = find (match_p == 75 & (~match_o) & (~boolFail));
    
    rasterLowR1 = getRaster(data1,indLowR,raster_params);
    rasterLowNR1 = getRaster(data1,indLowNR,raster_params);
    rasterHighR1 = getRaster(data1,indHighR,raster_params);
    rasterHighNR1 = getRaster(data1,indHighNR,raster_params);
    rasterLowR2 = getRaster(data2,indLowR,raster_params);
    rasterLowNR2 = getRaster(data2,indLowNR,raster_params);
    rasterHighR2 = getRaster(data2,indHighR,raster_params);
    rasterHighNR2 = getRaster(data2,indHighNR,raster_params);
    
    TC1(1) = mean(mean(rasterLowR1(comparison_window,:)));
    TC2(1) = mean(mean(rasterLowR2(comparison_window,:)));
    TC1(2) = mean(mean(rasterLowNR1(comparison_window,:)));
    TC2(2) = mean(mean(rasterLowNR2(comparison_window,:)));
    TC1(3) = mean(mean(rasterHighR1(comparison_window,:)));
    TC2(3) = mean(mean(rasterHighR2(comparison_window,:)));
    TC1(4) = mean(mean(rasterHighNR1(comparison_window,:)));
    TC2(4) = mean(mean(rasterHighNR2(comparison_window,:)));
    
    signalCorr(ii) = corr(TC1',TC2');
    
    %pause
end

figure;
ind = find(signalCorr>0);
subplot(2,2,1)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

ind = find(signalCorr<0);
subplot(2,2,3)
imagesc(squeeze(nanmean(jPSTHraw(ind,:,:))))
title ('Raw jPSTH')

subplot(2,2,4)
imagesc(squeeze(nanmean(jPSTHprod(ind,:,:))))
title ('jPSTH - Prod')

suptitle ([data1.info.cell_type '\' data1.info.cell_type ])



