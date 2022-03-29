
%% Pursuit task
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');


PROBABILITIES = [25,75]; 

figure 
req_params.grade = 6;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};


req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.ID = 4243;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparison_window = 100:800;
DIRECTIONS = 0:45:315;
PROBABILITIES = [25 75];
ts = -raster_params.time_before:raster_params.time_after;

for ii=1:length(cells)
    
    % cue
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    raster_params.align_to = 'cue';
    col = {'r','b'}; 
    
    
    ax = subplot(4,2,3);
    cla(ax)
    hold(ax,'on')
    xlabel('Time from cue')
        
    for p = 1:length(PROBABILITIES)
        
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        raster = getRaster(data,ind,raster_params);
        [psth,sem] = raster2psth(raster,raster_params);    
        
        subplot(4,4,p)
        
        plotRaster(raster,raster_params,col{p})
        xlabel('Time from cue')
        title([num2str(data.info.cell_ID) ' - ' data.info.cell_type ])
        
        errorbar(ax,ts,psth,sem,col{p})
        
    end
    
    
     
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
    
    subplot(4,4,14)
    
    plot(ts,psthHighR,'b');  hold on
    plot(ts,psthHighNR,'--b')
    plot(ts,psthLowNR,'--r');
    plot(ts,psthLowR,'r'); hold off
    xlabel('Time from reward')
    legend('R','NR')
    
    subplot(4,4,13)
    
    indR = find (match_o & (~boolFail));
    indNR = find ((~match_o) & (~boolFail));
    
    rasterR = getRaster(data,indR,raster_params);
    rasterNR = getRaster(data,indNR,raster_params);
    
    psthR = raster2psth(rasterR,raster_params);
    psthNR = raster2psth(rasterNR,raster_params);
    
    plot(ts,psthR,'b');  hold on
    plot(ts,psthNR,'r'); hold off
    legend('R','NR')
    
    
    % direction
    raster_params.align_to = 'targetMovementOnset';

    TC = getTC(data, 0:45:315,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, 0:45:315);
    colors = varycolor(length(DIRECTIONS));
    
    for d = 1:length(DIRECTIONS)
        
        inx = find (match_d == DIRECTIONS(d)& ~boolFail);
        
        raster = getRaster(data,inx, raster_params);
        subplot(11,2,2+2*(d-1))
        plotRaster(raster,raster_params)
        ylabel (num2str(DIRECTIONS(d)))
        xlabel('Time from movement')
        
        subplot(3,2,6)
        psthHigh = raster2psth(raster,raster_params);
        plot(ts,psthHigh,'Color',colors(d,:)); hold on
        title ('75')
        
        
    end
    
    subplot(3,2,6); hold off
    legend('0','45','90','135','180','225','270','315')
    pause
end

