clear all
load ('C:\noga\TD complex spike analysis\task_info');
tasks = {'saccade_8_dir_75and25'}
req_params.grade = 7;
req_params.num_trials = 50;
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;

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


%% Noise correlation during movement
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

angles = 0:45:315;
comparison_window = 100:300;
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
    [~,match_d] = getDirections (data1);

    boolFail = [data1.trials.fail];

    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    TC1 = getTC(data1,  angles, 1:length(data1.trials), comparison_window);
    TC2 = getTC(data2,  angles, 1:length(data1.trials), comparison_window);

    spkHigh1 =[];
    spkLow1 =[];
    spkHigh2 =[];
    spkLow2 =[];
    
    for d = 1:length(angles)
       
        inx = find (match_d == angles(d) &(~boolFail));
        
        rasterHigh1 = getRaster(data1,intersect(inx,indHigh), raster_params);
        rasterLow1 = getRaster(data1, intersect(inx,indLow), raster_params);
         rasterHigh2 = getRaster(data2,intersect(inx,indHigh), raster_params);
        rasterLow2 = getRaster(data2, intersect(inx,indLow), raster_params);
        
        
        spkHigh1 = [spkHigh1, mean(rasterHigh1)*1000 - TC1(d)];
        spkLow1 = [spkLow1, mean(rasterLow1)*1000 - TC1(d)];
        spkHigh2 = [spkHigh2, mean(rasterHigh2)*1000 - TC2(d)];
        spkLow2 = [spkLow2, mean(rasterLow2)*1000 - TC2(d)];

    end
    
    [NoiseCorrLow(ii),NoisepLow(ii)] = corr(spkLow1',spkLow2');
    [NoiseCorrHigh(ii),NoisepHigh(ii)] = corr(spkHigh1',spkHigh2');
    
end


figure;
intervals = 0.1;
[counts,centers] = hist(NoiseCorrLow,-1:intervals:1);
plot(centers, counts/length(cells),'r'); hold on
[counts,centers] = hist(NoiseCorrHigh,-1:intervals:1);
plot(centers, counts/length(cells),'b'); hold on

signrank(NoiseCorrLow,NoiseCorrHigh)



%% signal correlation
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

angles = 0:45:315;
comparison_window = 100:300;
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
    [~,match_d] = getDirections (data1);

    boolFail = [data1.trials.fail];

    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    TCLow1 = getTC(data1,  angles, indLow, comparison_window);
    TCLow2 = getTC(data2,  angles, indLow, comparison_window);
    TCHigh1 = getTC(data1,  angles, indHigh, comparison_window);
    TCHigh2 = getTC(data2,  angles, indHigh, comparison_window);
    
    [SignalCorrLow(ii),SpLow(ii)] = corr(TCLow1, TCLow2 );
    [SignalCorrHigh(ii),SpHigh(ii)] = corr(TCHigh1,TCHigh2);
    
    
    
end


figure;
intervals = 0.1;
[counts,centers] = hist(SignalCorrLow,-1:intervals:1);
plot(centers, counts/length(cells),'r'); hold on
[counts,centers] = hist(SignalCorrHigh,-1:intervals:1);
plot(centers, counts/length(cells),'b'); hold on

signrank(SignalCorrLow,SignalCorrHigh)


%% correlation between correlations
supPath = 'C:\noga\TD complex spike analysis\Data\albert\';


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;

angles = 0:45:315;
comparison_window = 100:300;
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
    
    boolFail = [data1.trials.fail];
    
    TC1 = getTC(data1,  angles, 1:length(data1.trials), comparison_window);
    TC2 = getTC(data2,  angles, 1:length(data2.trials), comparison_window);
    
    [SignalCorr(ii),Sp(ii)] = corr(TC1, TC2 );
    
    spk1 =[];
    spk2 =[];
    
    [~,match_d] = getDirections (data1);

    for d = 1:length(angles)
       
        inx = find (match_d == angles(d) &(~boolFail));
        
        raster1 = getRaster(data1,inx, raster_params);
        raster2 = getRaster(data2, inx, raster_params);
       
        spk1 = [spk1, mean(raster1)*1000 - TC1(d)];
        spk2 = [spk2, mean(raster2)*1000 - TC2(d)];

    end
    
    [NoiseCorr(ii),Noisep(ii)] = corr(spk1',spk2');
    
    
end


%%

figure;
scatter(SignalCorr, NoiseCorr,'filled'); hold on
ylim([-1 1]);xlim([-1 1])
[r,p] = corr(SignalCorr', NoiseCorr')







