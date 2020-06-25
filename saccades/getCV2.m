function CV2 = getCV2(data,ind,params)

for t = 1:length(ind)
    switch params.align_to
        case 'cue'
            tb = data.trials(t).cue_onset - params.time_before;
            te = data.trials(t).cue_onset + params.time_after;
            spikes = data.trials(t).spike_times;
        case 'targetMovementOnset'
            tb = data.trials(t).movement_onset - params.time_before;
            te = data.trials(t).movement_onset + params.time_after;
            spikes = data.trials(t).spike_times;
        case 'reward'
            tb = data.trials(t).rwd_time_in_extended - params.time_before;
            te = data.trials(t).rwd_time_in_extended + params.time_after;
            spikes = data.trials(t).extended_spike_times;
    end
   
    spikesInTime = spikes(spikes>tb & spikes<te);
    ISI = spikesInTime(2:end)-spikesInTime(1:end-1); 
    CV2(t) = mean(2*abs(ISI(2:end) - ISI(1:end-1))./(ISI(2:end) + ISI(1:end-1)));
    
    
end