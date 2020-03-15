clear all
load ('C:\noga\TD complex spike analysis\task_info');
tasks = {'saccade_8_dir_75and25','pursuit_8_dir_75and25'}
req_params.grade = 7;
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;
req_params.num_trials = 20;

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

%% Correlation during cue in each reward condition
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 100;

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;

ts = -raster_params.time_before:raster_params.time_after;

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
    
    [~,match_p] = getProbabilities (data1);
    boolFail = [data1.trials.fail];

    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow1 = getRaster(data1,indLow,raster_params);
    rasterHigh1 = getRaster(data1,indHigh,raster_params);
    rasterLow2 = getRaster(data2,indLow,raster_params);
    rasterHigh2 = getRaster(data2,indHigh,raster_params);
    
        for t = 1:length(ts)
            runningWindow = raster_params.smoothing_margins + t + timeWindow;
            spikesLow1 = sum(rasterLow1(runningWindow,:),1);
            spikesHigh1 = sum(rasterHigh1(runningWindow,:),1);
            spikesLow2 = sum(rasterLow2(runningWindow,:),1);
            spikesHigh2 = sum(rasterHigh2(runningWindow,:),1);
            [correlationLow(ii,t),pLow(ii,t)] = corr(spikesLow1',spikesLow2');
            [correlationHigh(ii,t),pHigh(ii,t)] = corr(spikesHigh1',spikesHigh2');
    
        end

    
end

% 
% figure;
% intervals = 0.1;
% [counts,centers] = hist(correlationLow,-1:intervals:1);
% plot(centers, counts/length(cells),'r'); hold on
% [counts,centers] = hist(correlationHigh,-1:intervals:1);
% plot(centers, counts/length(cells),'b'); hold on
% 
% signrank(correlationLow,correlationHigh)


figure;

aveCorrelationLow = nanmedian(correlationLow);
aveCorrelationHigh = nanmedian(correlationHigh);

plot(ts,aveCorrelationLow,'r'); hold on
plot(ts,aveCorrelationHigh,'b')


%% Noise Corr
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';


raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 100;

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;

ts = -raster_params.time_before:raster_params.time_after;

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
    
    data1 = getPreviousCompleted(data1,MaestroPath);
    [~,match_p] = getProbabilities (data1);
    boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];
    

    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    rasterLow1 = getRaster(data1,indLow,raster_params);
    rasterHigh1 = getRaster(data1,indHigh,raster_params);
    rasterLow2 = getRaster(data2,indLow,raster_params);
    rasterHigh2 = getRaster(data2,indHigh,raster_params);
    
        for t = 1:length(ts)
            runningWindow = raster_params.smoothing_margins + t + timeWindow;
            spikesLow1 = sum(rasterLow1(runningWindow,:),1) - mean(sum(rasterLow1(runningWindow,:),1));
            spikesHigh1 = sum(rasterHigh1(runningWindow,:),1) - mean(sum(rasterHigh1(runningWindow,:),1));
            spikesLow2 = sum(rasterLow2(runningWindow,:),1) - mean(sum(rasterLow2(runningWindow,:),1));
            spikesHigh2 = sum(rasterHigh2(runningWindow,:),1) - mean(sum(rasterHigh2(runningWindow,:),1));
            [NoiseCorre(ii,t),p(ii,t)] = corr([spikesLow1';spikesHigh1'],[spikesLow2';spikesHigh2']);
    
        end

    
end

% 
% figure;
% intervals = 0.1;
% [counts,centers] = hist(correlationLow,-1:intervals:1);
% plot(centers, counts/length(cells),'r'); hold on
% [counts,centers] = hist(correlationHigh,-1:intervals:1);
% plot(centers, counts/length(cells),'b'); hold on
% 
% signrank(correlationLow,correlationHigh)


figure;

aveCorrelationLow = nanmedian(NoiseCorre);
frac = mean(p<0.05)
plot(ts,aveCorrelationLow); hold on
plot(ts,frac)

