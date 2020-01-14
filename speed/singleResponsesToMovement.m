supPath = 'C:\noga\TD complex spike analysis\Data\albert\speed_2_dir_0,50,100';
load ('C:\noga\TD complex spike analysis\task_info');


req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
lines = lines(find ([task_info(lines).cue_differentiating]==1));

req_params.ID = [task_info(lines).cell_ID];
cells = findPathsToCells (supPath,task_info,req_params);


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
comparison_window = (100:500) + raster_params.time_before; % for TC


directions = [0 180];
velocities = [15,25];
ts = -raster_params.time_before:raster_params.time_after;

for ii = 1:length(cells)
    
    figure;
    data = importdata(cells{ii});
    [~,match_v] = getVelocities (data)
    [~,match_d] = getDirections (data);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    boolLow = (match_p == 0 & (~boolFail));
    boolMid = (match_p == 50 & (~boolFail));
    boolHigh = (match_p == 100 & (~boolFail));
    
    for d = 1:length(directions)
        for v = 1:length(velocities)
            
            rasterLow = getRaster(data,find(boolLow & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            rasterMid = getRaster(data,find(boolMid & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            rasterHigh = getRaster(data,find(boolHigh & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            
            
            rasterBaseline =  getRaster(data,find(~boolFail), raster_params);
            baseline = mean(mean(rasterBaseline))*1000;
            
            TCLow (v,d) = mean(mean(rasterLow(comparison_window,:)))*1000-baseline;
            TCMid (v,d) = mean(mean(rasterMid(comparison_window,:)))*1000-baseline;
            TCHigh (v,d) = mean(mean(rasterHigh(comparison_window,:)))*1000-baseline;
            
            psthLow(v,d,:) = raster2psth(rasterLow,raster_params)-baseline;
            psthMid(v,d,:) = raster2psth(rasterMid,raster_params)-baseline;
            psthHigh(v,d,:) = raster2psth(rasterHigh,raster_params)-baseline;
            
            subplot(4,3,6*(d-1)+3*(v-1)+1)
            plotRaster (rasterLow, raster_params)
            title (['vel = ' num2str(velocities(v)) ', dir = ' num2str(directions(d)) ', 0'])
            subplot(4,3,6*(d-1)+3*(v-1)+2)
            plotRaster (rasterMid, raster_params)
            title (['vel = ' num2str(velocities(v)) ', dir = ' num2str(directions(d)) ', 50'])
            subplot(4,3,6*(d-1)+3*(v-1)+3)
            plotRaster (rasterHigh, raster_params)
            title (['vel = ' num2str(velocities(v)) ', dir = ' num2str(directions(d)) ', 100'])
            suptitle (num2str(data.info.cell_ID))
        end
    end
    
    figure;
    
    subplot(3,2,1)
    
    Low = squeeze(psthLow(1,1,:));
    plot(ts,Low,'c'); hold on
    Low = squeeze(psthLow(2,1,:));
    plot(ts,Low,'k'); hold on
    title('Low, PD')
    legend('fast','slow')
    
    subplot(3,2,2)
    
    Low = squeeze(psthLow(1,2,:));
    plot(ts,Low,'c'); hold on
    Low = squeeze(psthLow(2,2,:));
    plot(ts,Low,'k'); hold on
    title('Low, Null')
    legend('fast','slow')
    
    subplot(3,2,3)
    
    Mid = squeeze(psthMid(1,1,:));
    plot(ts,Mid,'c'); hold on
    Mid = squeeze(psthMid(2,1,:));
    plot(ts,Mid,'k'); hold on
    title('Mid, PD')
    legend('fast','slow')
    
    subplot(3,2,4)
    
    Mid = squeeze(psthMid(1,2,:));
    plot(ts,Mid,'c'); hold on
    Mid = squeeze(psthMid(2,2,:));
    plot(ts,Mid,'k'); hold on
    title('Mid, Null')
    legend('fast','slow')
    
    
    subplot(3,2,5)
    
    High = squeeze(psthHigh(1,1,:));
    plot(ts,High,'c'); hold on
    High = squeeze(psthHigh(2,1,:));
    plot(ts,High,'k'); hold on
    title('High, PD')
    legend('fast','slow')
    
    subplot(3,2,6)
    
    High = squeeze(psthHigh(1,2,:));
    plot(ts,High,'c'); hold on
    High = squeeze(psthHigh(2,2,:));
    plot(ts,High,'k'); hold on
    title('High, Null')
    legend('fast','slow')
    
end


