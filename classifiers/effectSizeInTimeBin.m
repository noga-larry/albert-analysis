function [effectSizes, ts, low] = effectSizeInTimeBin(data,epoch,varargin)

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



for t=1:length(ts)
    
    if mean(response(t,:))<MINIMAL_RATE_IN_BIN
        low = 1;
    end
    
    switch epoch
        
        case 'cue'
            
            if strcmp(data.info.task,'choice')
                omegas = calOmegaSquare(response(t,:),groups, group_names, ...
                    'partial', true, 'includeTime',false);
                effectSizes(t).direction = omegas(1).value;
                effectSizes(t).reward = omegas(2).value;
            else
                omegas = calOmegaSquare(response(t,:),groups, group_names,...
                    'partial',true,...
                    'includeTime',false);
                effectSizes(t).reward = omegas(1).value;
            end
            
        case {'targetMovementOnset','saccadeLatency','pursuitLatencyRMS'}
            omegas = calOmegaSquare(response(t,:),groups, group_names,'partial',true,...
                'includeTime',false);
            effectSizes(t).direction = omegas(1).value;
            effectSizes(t).reward = omegas(2).value;
            
        case 'reward'
            omegas = calOmegaSquare(response(t,:),groups, group_names,...
                'partial',true,'model','interaction', 'includeTime',false);
            effectSizes(t).reward = omegas(1).value;
            effectSizes(t).direction = omegas(2).value;
            effectSizes(t).outcome = omegas(3).value;
            effectSizes(t).prediction = omegas(4).value;
            
            
    end   
    
    if prevOut
        effectSizes(t).prev_out = omegas(end-1).value;
    end
    
    if length(groups)>1
        effectSizes(t).interactions = omegas(end).value;
    end
end


end
