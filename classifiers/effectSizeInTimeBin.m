function [effectSizes, ts] = effectSizeInTimeBin(data,epoch)

raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0;

BIN_SIZE = 50;

PROBABILITIES = 0:25:100;

raster_params.align_to = epoch;

boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

if strcmp(data.info.task,'choice')
    boolFail = [data.trials.fail] | ~[data.trials.choice] |...
        ~[data.trials.previous_completed];
end

ind = find(~boolFail);

if strcmp(data.info.task,'rwd_direction_tuning') % FLOCCULUS TASK!
    [~,match_p] = getRewardSize (data,ind,'omitNonIndexed',true);
elseif strcmp(data.info.task,'choice')
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_d = match_d(1,:);
else
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
end

match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
[match_o] = getOutcome (data,ind,'omitNonIndexed',true);

raster = getRaster(data,find(~boolFail),raster_params);
response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);


ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

for t=1:length(ts)
    
    switch epoch
        
        case 'cue'
            
            if strcmp(data.info.task,'choice')
                omegas = calOmegaSquare(response(t,:),{match_d,match_p},'partial',...
                    true, 'includeTime',false);
                effectSizes(t).direction = omegas(1).value;
                effectSizes(t).reward = omegas(2).value;
                effectSizes(t).interactions = omegas(3).value;
            else
                omegas = calOmegaSquare(response(t,:),{match_p},'partial',true,...
                    'includeTime',false);
                effectSizes(t).reward = omegas(1).value;
            end
            
        case 'targetMovementOnset'
            omegas = calOmegaSquare(response(t,:),{match_d,match_p},'partial',true,...
                'includeTime',false);
            effectSizes(t).direction = omegas(1).value;
            effectSizes(t).reward = omegas(2).value;
            effectSizes(t).interactions = omegas(3).value;
            
        case 'reward'
            omegas = calOmegaSquare(response(t,:),{match_p,match_d,match_o},...
                'partial',true,'model','interaction', 'includeTime',false);
            effectSizes(t).reward = omegas(1).value;
            effectSizes(t).direction = omegas(2).value;
            effectSizes(t).outcome = omegas(3).value;
            effectSizes(t).interactions = omegas(4).value;

    end
end