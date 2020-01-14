supPath = 'C:\noga\TD complex spike analysis\Data\albert\speed_2_dir_0,50,100';
load ('C:\noga\TD complex spike analysis\task_info');


req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000;
req_params.num_trials = 30;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
lines = lines( find ([task_info(lines).cue_differentiating]==1));

req_params.ID = [task_info(lines).cell_ID];
cells = findPathsToCells (supPath,task_info,req_params);


raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

ts = -raster_params.time_before:raster_params.time_after;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    indLow = find (match_p == 0 & (~boolFail));
    indMid = find (match_p == 50 & (~boolFail));
    indHigh = find (match_p == 100 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterMid = getRaster(data,indMid,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    
    psthLow = raster2psth(rasterLow,raster_params);
    psthMid = raster2psth(rasterMid,raster_params);
    psthHigh = raster2psth(rasterHigh,raster_params);
    h(ii) = task_info(lines(ii)).cue_differentiating;
    
    figure;
    subplot(2,3,1)
    plotRaster (rasterLow, raster_params)
    title ('0')
    subplot(2,3,2)
    plotRaster (rasterMid, raster_params) 
    title ('50')
    subplot(2,3,3)
    plotRaster (rasterHigh, raster_params)
    title ('100')
    subplot(2,1,2)
    plot(ts,psthLow,'r'); hold on
    plot(ts,psthMid,'k')
    plot(ts,psthHigh,'b')
    legend ('0', '50', '100')
    
    
    
    
end


