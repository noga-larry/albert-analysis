
%% Pursuit task
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');
     
req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = [4000:5000];
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparison_window = 100:300;
angles = [0:45:180];
ts = -raster_params.time_before:raster_params.time_after;

for ii=1:length(cells)
    
    % cue
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    raster_params.align_to = 'cue';
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    rasterLow = getRaster(data,indLow,raster_params);
    rasterHigh = getRaster(data,indHigh,raster_params);
    psthLow = raster2psth(rasterLow,raster_params);
    psthHigh = raster2psth(rasterHigh,raster_params);
    
    subplot(4,4,1)
    plotRaster(rasterLow,raster_params,'r')
    xlabel('Time from cue')
    title(num2str(data.info.cell_ID))
    subplot(4,4,2)
    plotRaster(rasterHigh,raster_params,'b')
    xlabel('Time from cue')
    subplot(4,2,3)
    plot(ts,psthLow,'r'); hold on
    plot(ts,psthHigh,'b'); hold off
    xlabel('Time from cue')
    
    % reward
    raster_params.align_to = 'reward';

    indLowR = find (match_p == 25 & match_o & (~boolFail));
    indLowNR = find (match_p == 25 & (~match_o) & (~boolFail));
    indHighR = find (match_p == 75 & match_o & (~boolFail));
    indHighNR = find (match_p == 75 & (~match_o) & (~boolFail));
    
    rasterLowR = getRaster(data,indLowR,raster_params);
    rasterLowNR = getRaster(data,indLowNR,raster_params);
    rasterHighR = getRaster(data,indHighR,raster_params);
    rasterHighNR = getRaster(data,indHighNR,raster_params);
    
    psthLowR = raster2psth(rasterLowR,raster_params);
    psthLowNR = raster2psth(rasterLowNR,raster_params);
    psthHighR = raster2psth(rasterHighR,raster_params);
    psthHighNR = raster2psth(rasterHighNR,raster_params);
    
    subplot(8,4,17)
    plotRaster(rasterLowR,raster_params,'r')
    title ('Reward')
    subplot(8,4,21)
    plotRaster(rasterLowNR,raster_params,'r')
    title ('No Reward')
    xlabel('Time from reward')
    subplot(8,4,22)
    plotRaster(rasterHighNR,raster_params,'b')
    title ('No reward')
    subplot(8,4,18)
    plotRaster(rasterHighR,raster_params,'b')
    xlabel('Time from reward')
    title ('Reward')
    subplot(4,2,7)
    plot(ts,psthHighR,'b');  hold on
    plot(ts,psthHighNR,'--b')
    plot(ts,psthLowNR,'--r');
    plot(ts,psthLowR,'r'); hold off
    xlabel('Time from reward')
    legend('R','NR')
    
    
    % direction
    raster_params.align_to = 'targetMovementOnset';

    TC = getTC(data, 0:45:315,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, 0:45:315);
    colors = varycolor(length(angles));
    
    for d = 1:length(angles)
        
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        rasterHigh = getRaster(data,intersect(inx,indHigh), raster_params);
        subplot(8,4,3+4*(d-1))
        plotRaster(rasterHigh,raster_params,'b')
        ylabel (num2str(angles(d)))
        xlabel('Time from movement')
        rasterLow = getRaster(data, intersect(inx,indLow), raster_params);
        subplot(8,4,4+4*(d-1))
        plotRaster(rasterLow,raster_params,'r')
        ylabel (num2str(angles(d)))
        xlabel('Time from movement')
        
        subplot(3,4,11)
        psthHigh = raster2psth(rasterHigh,raster_params)-mean(TC);
        plot(ts,psthHigh,'Color',colors(d,:)); hold on
        title ('75')
        
        subplot(3,4,12)
        psthLow = raster2psth(rasterLow,raster_params)-mean(TC);
        plot(ts,psthLow,'Color',colors(d,:)); hold on
        title ('25')
        xlabel('Time from movement')
        
    end
    
    subplot(3,4,11); hold off
    subplot(3,4,12); hold off
    legend('0','45','90','125','180')
    pause
end

