%% Significance as function of time, trials without saccade

clear all

supPath = 'C:\noga\TD complex spike analysis\Data\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 40;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.time_before = 300;
raster_params.time_after = 2000;
raster_params.smoothing_margins = 50; % ms in each side

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before : raster_params.time_after;


HighTail = nan(length(cells),length(ts));
LowTail =nan(length(cells),length(ts));

timeWindow = -raster_params.smoothing_margins:...
    raster_params.smoothing_margins;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    boolSaccade = cellfun(@(b) any(b>500 & b<1000),{data.trials.beginSaccade});
     
    boolFail = [data.trials.fail] | ~[ data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail) & ~boolSaccade);
    indHigh = find (match_p == 75 & (~boolFail) & ~boolSaccade);
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spksHigh = sum(rasterHigh(runningWindow,:));
        spksLow = sum(rasterLow(runningWindow,:));
        [~,HighTail(ii,t)] = ranksum(spksHigh,spksLow,'tail','right');
        [~,LowTail(ii,t)] = ranksum(spksHigh,spksLow,'tail','left');
    end
end

fracHighTail = mean(HighTail>0.05);
fracLowTail = mean(LowTail>0.05);
figure;
plot(ts,fracHighTail,'b'); hold on
plot(ts,fracLowTail,'r')
xlabel('Time from cue')
ylabel('Frac of cells')