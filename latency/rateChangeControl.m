function lat = rateChangeControl(data,trailInxArray,curGroup,epoch,plotOption)

NUM_SETS = 8;

partitions = getNonOverlappingPartions(trailInxArray,NUM_SETS);

% get baseline

baseline_params.SD = 20;
baseline_params.align_to = epoch;
baseline_params.time_before = 500;
baseline_params.time_after = 0;
baseline_params.smoothing_margins = 100;


baselinePsth = [];
for i=1:length(partitions{1,2})
    baselinePsth = [baselinePsth;getPSTH(data,partitions{1,2}{i},baseline_params)];
end

% get response

response = getPSTH(data,partitions{1,1}{1},baseline_params);

lat = latencyFromBaseline(baselinePsth,response);

if plotOption

    ts = -response_params.time_before:response_params.time_after;
    ax1= subplot(2,1,1);
    psth = getPSTH(data,trailInxArray{curGroup},response_params);
    plot(ts,psth); hold on
    if ~isnan(lat)
        plot(ts(response_params.time_before+lat),psth(response_params.time_before+lat),'*')
    end
    yline(bottomThresh)
    yline(upperThresh)
    xline(0)

    ax2 = subplot(2,1,2);
    raster = getRaster(data,trailInxArray{curGroup},response_params);
    plotRaster(raster,response_params,'k')

    pause
    cla(ax1); cla(ax2);
end
end