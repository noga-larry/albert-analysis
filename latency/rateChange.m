function lat = rateChange(data,trailInxArray,curGroup,epoch,plotOption)



% get baseline

baseline_params.SD = 20;
baseline_params.align_to = epoch;
baseline_params.time_before = 500;
baseline_params.time_after = 0;
baseline_params.smoothing_margins = 100;

response_params.time_before = 0;
response_params.time_after = 800;
response_params.smoothing_margins = 100;
response_params.align_to = epoch;
response_params.SD = 20;

baselinePsth = [];
for i=1:length(trailInxArray)
    baselinePsth = [baselinePsth;getPSTH(data,trailInxArray{i},baseline_params)];
end

% get response

response_params.SD = response_params.SD;
response_params.align_to = response_params.align_to;
response_params.time_before = 0;
response_params.time_after =  response_params.time_after;
response_params.smoothing_margins = response_params.smoothing_margins;

response = getPSTH(data,trailInxArray{curGroup},response_params);

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