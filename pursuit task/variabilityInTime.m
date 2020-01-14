clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 50; % ms in each side
raster_params.SD = 10; % ms in each side

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before : raster_params.time_after;


for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getPreviousCompleted(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[ data.trials.previous_completed];
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    psthHigh = raster2psth(rasterHigh,raster_params);
    psthLow = raster2psth(rasterLow,raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spksHigh = sum(rasterHigh(runningWindow,:));
        spksLow = sum(rasterLow(runningWindow,:));
        tot_mean = mean([spksHigh, spksLow]);
        ssb = length(spksHigh)*((mean(spksHigh) - tot_mean)^2) + ...
            length(spksLow)*((mean(spksLow) - tot_mean)^2);
        sst = sum(([spksHigh, spksLow]-tot_mean).^2);
        etta(ii,t) = ssb/sst;
    end
end

aveEtta = nanmean(etta);
semEtta = nanstd(etta)/length(cells); 
figure;
errorbar(ts,aveEtta,semEtta); 
xlabel('Time from cue')
ylabel('Etta')