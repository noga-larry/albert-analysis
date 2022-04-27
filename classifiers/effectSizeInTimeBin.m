function [effectSizes, ts, low] = effectSizeInTimeBin(data,epoch,varargin)

MINIMAL_RATE_IN_BIN =0.001;
BIN_SIZE = 100;
PROBABILITIES = 0:25:100;

low=0;
p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);

parse(p,varargin{:})
prev_out = p.Results.prevOut;

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

groups = createGroups(data,epoch,ind,prev_out);

raster = getRaster(data,find(~boolFail),raster_params);
response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);


ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

for t=1:length(ts)
    
    if mean(response(t,:))<MINIMAL_RATE_IN_BIN;
        low = 1;
    end
    
    switch epoch
        
        case 'cue'
            
            if strcmp(data.info.task,'choice')
                omegas = calOmegaSquare(response(t,:),groups,'partial',...
                    true, 'includeTime',false);
                effectSizes(t).direction = omegas(1).value;
                effectSizes(t).reward = omegas(2).value;
            else
                omegas = calOmegaSquare(response(t,:),groups,'partial',true,...
                    'includeTime',false);
                effectSizes(t).reward = omegas(1).value;
            end
            
        case 'targetMovementOnset'
            omegas = calOmegaSquare(response(t,:),groups,'partial',true,...
                'includeTime',false);
            effectSizes(t).direction = omegas(1).value;
            effectSizes(t).reward = omegas(2).value;
            
        case 'reward'
            omegas = calOmegaSquare(response(t,:),groups,...
                'partial',true,'model','interaction', 'includeTime',false);
            effectSizes(t).reward = omegas(1).value;
            effectSizes(t).direction = omegas(2).value;
            effectSizes(t).outcome = omegas(3).value;
            
            
    end   
    
    if prev_out
        effectSizes(t).prev_out = omegas(end-1).value;
    end
    
    if length(groups)>1
        effectSizes(t).interactions = omegas(end).value;
    end
end


end
