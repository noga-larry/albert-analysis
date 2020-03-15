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
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 50;
raster_params.plot_cell = 0;


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

    indSets{1} = find ((~boolFail) & match_p == 75);
    indSets{2} = find ((~boolFail) & match_p == 25);

    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:),Prod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
    
    %pause
end

ts = -raster_params.time_before:raster_params.bin_size:raster_params.time_after;

   
figure;
subplot(2,2,1)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw))); colorbar
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(ts,ts,squeeze(nanmean(Prod))); colorbar
title ('Prod')

subplot(2,2,3)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw - Prod))); colorbar
title ('jPSTH - Prod')

subplot(2,2,4)
imagesc(ts,ts,squeeze(nanmean(jPSTHprod))); colorbar
title ('jPSTH - Prod/ normalization')




%% movement

supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'targetMovementOnset';
raster_params.time_before = 500;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 50;
raster_params.plot_cell = 1;

directions = 0:45:315;


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
    [~,match_d] = getDirections (data1);

    
    for d = 1:length(directions)
    indSets{d} = find ((~boolFail) & match_d == directions(d));
    end

    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:),Prod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
    
    pause
end


ts = -raster_params.time_before:raster_params.bin_size:raster_params.time_after;

   
figure;
subplot(2,2,1)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw)))
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(ts,ts,squeeze(nanmean(Prod)))
title ('Prod')

subplot(2,2,3)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw - Prod)))
title ('jPSTH - Prod')

subplot(2,2,4)
imagesc(ts,ts,squeeze(nanmean(jPSTHprod)))
title ('jPSTH - Prod/ normalization')


%% reward


supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'reward';
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 50;
raster_params.plot_cell = 1;

directions = 0:45:315;


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
    
    [jPSTHraw(ii,:,:),jPSTHprod(ii,:,:),Prod(ii,:,:)] = jPSTH(data1,data2,indSets,raster_params);
    
   pause
end


ts = -raster_params.time_before:raster_params.bin_size:raster_params.time_after;

   
figure;
subplot(2,2,1)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw)))
title ('Raw jPSTH')

subplot(2,2,2)
imagesc(ts,ts,squeeze(nanmean(Prod)))
title ('Prod')

subplot(2,2,3)
imagesc(ts,ts,squeeze(nanmean(jPSTHraw - Prod)))
title ('jPSTH - Prod')

subplot(2,2,4)
imagesc(ts,ts,squeeze(nanmean(jPSTHprod)))
title ('jPSTH - Prod/ normalization')



