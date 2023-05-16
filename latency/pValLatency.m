function lat = pValLatency(data,inx,plotOption,effectSize)

FIRST_RUNNING_WINDOW = -50:50;
SECOND_RUNNING_WINDOW = -10:10;
TIME_BEFORE = 0;
TIME_AFTER = 800;
DIRECTIONS = 0:45:315;
FIRST_INTERVALS = 5;
SECOND_INTERVALS = 3;
NUM_CONSECUTIVE_FIRST = 4;
NUM_CONSECUTIVE_SECOND = 4;


ts = -TIME_BEFORE:FIRST_INTERVALS:TIME_AFTER;
consecutive_counter = 0;

for t=1:length(ts)
    comparison_window = ts(t)+FIRST_RUNNING_WINDOW;
    [~,~,h] = getTC(data, DIRECTIONS, inx, comparison_window);
    if h
        consecutive_counter = consecutive_counter+1;
    else
        consecutive_counter=0;
    end
    
    if consecutive_counter==NUM_CONSECUTIVE_FIRST
        break
    end
end

if consecutive_counter~=NUM_CONSECUTIVE_FIRST
    lat=nan;
else
    first_localization_estimate = (ts(max(1,t-NUM_CONSECUTIVE_FIRST))+min(FIRST_RUNNING_WINDOW))...
        :SECOND_INTERVALS:...
        (ts(t)+max(FIRST_RUNNING_WINDOW));

    consecutive_counter = 0;
    for t=1:length(first_localization_estimate)
        comparison_window = first_localization_estimate(t)+SECOND_RUNNING_WINDOW;
        [~,pvals(t),h(t)] = getTC(data, DIRECTIONS, inx, comparison_window);
        if h(t)
            consecutive_counter = consecutive_counter+1;
        else
            consecutive_counter=0;
        end

        if consecutive_counter==NUM_CONSECUTIVE_SECOND
            break
        end
    end
end

if consecutive_counter~=NUM_CONSECUTIVE_SECOND
    lat=nan;
    else
    lat = first_localization_estimate(t-ceil(NUM_CONSECUTIVE_SECOND/2));
end


if plotOption
    
    raster_params.time_before = TIME_BEFORE;
    raster_params.time_after = TIME_AFTER;
    raster_params.smoothing_margins = 0; 
    raster_params.align_to = 'targetMovementOnset'; 
    
    [~,match_d] = getDirections(data,inx);
    [~,p] = sort(match_d(inx));
    inx = inx(p);
    
    raster = getRaster(data,inx, raster_params);
    plotRaster(raster,raster_params,match_d(inx))
    xlabel('Time from movement')
    
    if ~isnan(lat)
        xline(lat)
    end
    
    title(num2str(effectSize))
    %pause
    cla
end


end