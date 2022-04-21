function effectSizes = effectSizeInEpoch(data,epoch,varargin)


p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);

parse(p,varargin{:})
prev_out = p.Results.prevOut;

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
bin_sz = 50;

raster_params.align_to = epoch;


boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

if strcmp(data.info.task,'choice')
    boolFail = [data.trials.fail] | ~[data.trials.choice] |...
        ~[data.trials.previous_completed];
end

ind = find(~boolFail);

groups = createGroups(data,epoch,ind,prev_out);

raster = getRaster(data,find(~boolFail),raster_params);

p = randperm(size(raster,2));
raster = raster(:,p);
raster = [binornd(1,0.01,100, size(raster,2)); binornd(1,0.02, 100, size(raster,2));...
    binornd(1,0.03,100, size(raster,2)); binornd(1,0.04, 100, size(raster,2));...
    binornd(1,0.05,100, size(raster,2)); binornd(1,0.06, 100, size(raster,2));...
    binornd(1,0.07,100, size(raster,2)); binornd(1,0.08, 101, size(raster,2))];

response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);


switch epoch
    case 'cue'
        
        if strcmp(data.info.task,'choice')
            omegas = calOmegaSquare(response,groups,'partial',true);
            effectSizes.time = omegas(1).value;
            effectSizes.direction = omegas(2).value;
            effectSizes.reward = omegas(3).value;
        else
            omegas = calOmegaSquare(response,groups,'partial',true);
            effectSizes.time = omegas(1).value;
            effectSizes.reward = omegas(2).value;
        end

    case 'targetMovementOnset'
        omegas = calOmegaSquare(response,groups,'partial',true);
        effectSizes.time = omegas(1).value;
        effectSizes.direction = omegas(2).value;
        effectSizes.reward = omegas(3).value;
        
    case 'reward'
        omegas = calOmegaSquare(response,groups,'partial',true,'model','interaction');
        effectSizes.time = omegas(1).value;
        effectSizes.reward = omegas(2).value;
        effectSizes.direction = omegas(3).value;
        effectSizes.outcome = omegas(4).value;        
end

if length(groups)>1
    effectSizes.interactions = omegas(end).value;
end