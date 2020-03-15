clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 700;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    TCHigh = getTC(data, directions,inxHigh, comparison_window);
    TCLow = getTC(data, directions,inxLow, comparison_window);
    
    spikesHigh = [];
    spikesLow = [];
    RTsHigh = [];
    RTsLow = [];
    for d = 1:length(directions)
        
        inx = find (match_d == directions(d)|(~boolFail));

        rasterHigh = getRaster(data,intersect(inx,inxHigh), raster_params);
        rasterLow = getRaster(data, intersect(inx,inxLow), raster_params);
        spikesHigh = [spikesHigh, mean(rasterHigh)*1000 - TCHigh(d)];
        spikesLow = [spikesLow, mean(rasterLow)*1000 - TCLow(d)];
        
        RTs = saccadeRTs(data,intersect(inx,inxHigh));
        RTsHigh = [RTsHigh,RTs - mean(RTs)];
        RTs = saccadeRTs(data,intersect(inx,inxLow));
        RTsLow = [RTsLow,RTs - mean(RTs)];
        
       
    end
     correlationHigh(ii) = corr(spikesHigh',RTsHigh');
     correlationLow(ii) = corr(spikesLow',RTsLow');
    
    
end




figure;
scatter(correlationHigh,correlationLow)
signrank(correlationHigh,correlationLow)

refline(1,0)
xlabel('High'); ylabel('Low')
