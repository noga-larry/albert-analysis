function lat = latencyFromBaseline(baseline,response)
SD_THRESHOLD = 5;

baselineSD = std(baseline);
baselineAve = mean(baseline);

if baselineSD == 0
    lat = nan;
    return
end

bottomThresh = baselineAve - SD_THRESHOLD*baselineSD;
upperThresh = baselineAve + SD_THRESHOLD*baselineSD;

lat = find(response>upperThresh | response<bottomThresh,1);

if isempty(lat)
    disp('Latency not found')
    lat = nan;
end
end
