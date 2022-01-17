function [r,p_val] = NB_corr(data,raster_params,prob,directions)
spikes =[];
RTs =[];
boolFail = [data.trials.fail];
[~,match_p] = getProbabilities (data);
[~,match_d] = getDirections (data);

% substract RT average in direction to reduce directional variance
for d = 1:length(directions)
    inx = find (match_p == prob & (~boolFail)...
        & match_d == directions(d));
    
    raster = getRaster(data,inx, raster_params);
    spikes = [spikes, mean(raster)*1000];
    
    RTs_dir = saccadeRTs(data,inx);
    RTs = [RTs, RTs_dir - nanmean(RTs_dir)];
end
[r,p_val] = corr(spikes',RTs','Rows','Pairwise');

end