clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = [25,75];

req_params.grade = 7;
req_params.ID = 4243;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;
req_params.remove_repeats = false;

raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.align_to = 'cue';

lines = findCspkSspkPairs(task_info,req_params);

cells = findPathsToCells (supPath,task_info,[lines(1),lines(2)]);
data1 = importdata(cells{1});
data2 = importdata(cells{2});
[data1,data2] = reduceToSharedTrials(data1,data2);
   
boolFail = [data2.trials.fail];
[~,match_p] = getProbabilities(data2);

for p=1:length(PROBABILITIES)
    ind = find (~boolFail & match_p==PROBABILITIES(p));
    raster1 = getRaster(data1,ind,raster_params);
    raster2 = getRaster(data2,ind,raster_params);
    subplot(2,2,(p-1)*2+1)
    plotRaster(raster1,raster_params)
    subplot(2,2,(p-1)*2+2)
    plotRaster(raster2,raster_params)
end



