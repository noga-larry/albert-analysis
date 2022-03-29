function effectSizes = effectSizeInEpoch(data,epoch)

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
bin_sz = 50;


raster_params.align_to = epoch;


boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
ind = find(~boolFail);

[~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
[~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
[match_o] = getOutcome (data,ind,'omitNonIndexed',true);

raster = getRaster(data,find(~boolFail),raster_params);
response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);

switch epoch
    case 'cue'
        omegas = calOmegaSquare(response,{match_p},'partial',true);
        effectSizes.time = omegas(1).value;
        effectSizes.reward = omegas(2).value+omegas(3).value;
    case 'targetMovementOnset'
        omegas = calOmegaSquare(response,{match_d,match_p},'partial',true);
        effectSizes.time = omegas(1).value;
        effectSizes.direction = omegas(2).value+omegas(4).value;
        effectSizes.reward = omegas(3).value+omegas(5).value;
    case 'reward'        
        omegas = calOmegaSquare(response,{match_p,match_d,match_o},'partial',true,'model','interaction');   
        effectSizes.time = omegas(1).value;
        effectSizes.reward = omegas(2).value + omegas(5).value;
        effectSizes.direction = omegas(3).value + omegas(6).value;
        effectSizes.outcome = omegas(4).value + omegas(7).value;        
end