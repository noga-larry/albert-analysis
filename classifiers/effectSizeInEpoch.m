function [effectSizes, tbl, rate, numTrials] = effectSizeInEpoch(data,epoch,varargin)


p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);

defaultBinSize = 50;
addOptional(p,'binSize',defaultBinSize,@isnumeric);

parse(p,varargin{:})
prev_out = p.Results.prevOut;
bin_sz = p.Results.binSize;

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;

raster_params.align_to = epoch;

boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

if strcmp(data.info.task,'choice')
    boolFail = [data.trials.fail] | ~[data.trials.choice] |...
        ~[data.trials.previous_completed];
end

ind = find(~boolFail);
numTrials = length(ind);


[groups, group_names]= createGroups(data,epoch,ind,prev_out);
group_names = {'time', group_names{:}};

raster = getRaster(data,ind,raster_params);
rate = mean(raster,"all")*1000;

% p = randperm(size(raster,2));
% raster = raster(:,p);
% raster = [binornd(1,0.01,100, size(raster,2)); binornd(1,0.04, 100, size(raster,2));...
%     binornd(1,0.07,100, size(raster,2)); binornd(1,0.1, 100, size(raster,2));...
%     binornd(1,0.15,100, size(raster,2)); binornd(1,0.2, 100, size(raster,2));...
%     binornd(1,0.23,100, size(raster,2)); binornd(1,0.3, 101, size(raster,2))];

response = downSampleToBins(raster',bin_sz)'*(bin_sz);


switch epoch
    case 'cue'
        
        if strcmp(data.info.task,'choice')
            [omegas, tbl] = calOmegaSquare(response,groups,group_names,'partial',true);
            effectSizes.time = omegas(1).value;
            effectSizes.direction = omegas(2).value;
            effectSizes.reward = omegas(3).value;
        else
            [omegas, tbl] = calOmegaSquare(response,groups,group_names,'partial',true);
            effectSizes.time = omegas(1).value;
            effectSizes.reward = omegas(2).value;
        end

    case 'targetMovementOnset'
        [omegas, tbl] = calOmegaSquare(response,groups,group_names,'partial',true);
        effectSizes.time = omegas(1).value;
        effectSizes.direction = omegas(2).value;
        effectSizes.reward = omegas(3).value;
        
    case 'reward'
        [omegas, tbl] = calOmegaSquare(response,groups,group_names,'partial',true);
        effectSizes.time = omegas(1).value;
        effectSizes.reward = omegas(2).value;
        effectSizes.direction = omegas(3).value;
        effectSizes.outcome = omegas(4).value;  
        effectSizes.prediction = omegas(5).value;   
end

if length(groups)>1
    effectSizes.interactions = omegas(end).value;
end