function [response,ind,ts] = data2response(data,epoch)


BIN_SIZE = 50;


raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0;
raster_params.align_to = epoch;


boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
if strcmp(data.info.task,'choice')
    boolFail = [data.trials.fail] | ~[data.trials.choice] |...
        ~[data.trials.previous_completed];
end

ind = find(~boolFail);

raster = getRaster(data,find(~boolFail),raster_params);
response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;
