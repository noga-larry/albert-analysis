function [effectSizes, ts, low, pVals] = effectSizeInTimeBin(data,epoch,varargin)

MINIMAL_RATE_IN_BIN = 0.001;

low=0;
p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);
defaultVelocity = false;
addOptional(p,'velocityInsteadReward',defaultVelocity,@islogical);
defaultNumCorrectiveSaccades = false;
addOptional(p,'numCorrectiveSaccadesInsteadOfReward',defaultNumCorrectiveSaccades,@islogical);


parse(p,varargin{:})
prevOut = p.Results.prevOut;
velocityInsteadReward = p.Results.velocityInsteadReward  ;
numCorrectiveSaccadesInsteadOfReward = p.Results.numCorrectiveSaccadesInsteadOfReward;

[response,ind,ts] = data2response(data,epoch);

[groups, group_names] = createGroups(data,epoch,ind,prevOut,velocityInsteadReward,...
    numCorrectiveSaccadesInsteadOfReward);

model = 'full';

for t=1:length(ts)

    if mean(response(t,:))<MINIMAL_RATE_IN_BIN
        low = 1;
    end

    [omegas, ~, pVals] = calOmegaSquare(response(t,:),groups, group_names,'partial',true,...
        'includeTime',false,'model',model);
    for i=1:length(omegas)
        effectSizes(t).(omegas(i).variable) = omegas(i).value;
        pVals(t).(pVals(i).variable) = pVals(i).value;
    end
end

end
