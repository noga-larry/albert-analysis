function [effectSizes, tbl, rate, numTrials, pValsOutput] = ...
    effectSizeInEpoch(data,epoch,varargin)


p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);

defaultBinSize = 50;
addOptional(p,'binSize',defaultBinSize,@isnumeric);

defaultVelocity = false;
addOptional(p,'velocityInsteadReward',defaultVelocity,@islogical);

defaultNumCorrectiveSaccades = false;
addOptional(p,'numCorrectiveSaccadesInsteadOfReward',defaultNumCorrectiveSaccades,@islogical);

parse(p,varargin{:})
prevOut = p.Results.prevOut;
binSz = p.Results.binSize;
velocityInsteadReward = p.Results.velocityInsteadReward;
numCorrectiveSaccadesInsteadOfReward = p.Results.numCorrectiveSaccadesInsteadOfReward;

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


[groups, group_names] = createGroups(data,epoch,ind,...
    prevOut,velocityInsteadReward,numCorrectiveSaccadesInsteadOfReward);

group_names = {'time', group_names{:}};

raster = getRaster(data,ind,raster_params);
rate = mean(raster,"all")*1000;

% p = randperm(size(raster,2));
% raster = raster(:,p);
% raster = [binornd(1,0.01,100, size(raster,2)); binornd(1,0.04, 100, size(raster,2));...
%     binornd(1,0.07,100, size(raster,2)); binornd(1,0.1, 100, size(raster,2));...
%     binornd(1,0.15,100, size(raster,2)); binornd(1,0.2, 100, size(raster,2));...
%     binornd(1,0.23,100, size(raster,2)); binornd(1,0.3, 101, size(raster,2))];

response = downSampleToBins(raster',binSz)'*(binSz);

model = 'full';

[omegas, tbl, pVals] = calOmegaSquare(response,groups,group_names,'partial',true...
    ,'model',model);

for i=1:length(omegas)
    effectSizes.(omegas(i).variable) = omegas(i).value;
    pValsOutput.(pVals(i).variable) = pVals(i).value;
end
