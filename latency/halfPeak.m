
function lat = halfPeak(data,inx,raster_params,plot_option)

psth = getPSTH(data,inx,raster_params);
baselineRate = mean(psth(1:(raster_params.time_before)));
response = psth((raster_params.time_before):end);
if mean(response)>baselineRate
    [peakRate,inxPeak] = max(psth((raster_params.time_before):end));
    inxPeak = raster_params.time_before + inxPeak-1;
    halfPeakThreshold = baselineRate + (peakRate - baselineRate)/2;
    lat = find(response>halfPeakThreshold,1)-1;
else
    [peakRate,inxPeak] = min(psth((raster_params.time_before):end));
    inxPeak = raster_params.time_before + inxPeak -1;
    halfPeakThreshold = baselineRate+(peakRate - baselineRate)/2;
    lat = find(response<halfPeakThreshold,1)-1;
end

if isempty(lat)
    disp('Latency not found')
    lat = nan;
    return
end

if plot_option
    plot(psth); hold on
    plot(inxPeak,psth(inxPeak),'*')
    xline(raster_params.time_before)
    xline(raster_params.time_before+lat)
    yline(halfPeakThreshold)
    pause
    cla
end

end
