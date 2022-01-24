function [r,p_val] = NB_corr_with_prev_outcome...
    (data,raster_params,directions,ind)

spikes =[];
RTs =[];
boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
boolFail(1) = true;
[~,match_d] = getDirections (data);

% substract RT average in direction to reduce directional variance
for d = 1:length(directions)
    inx = intersect(ind, find ((~boolFail)...
        & match_d == directions(d)));
    
    inx_prev = inx-1;
    raster = getRaster(data,inx_prev, raster_params);
    spikes = [spikes, mean(raster)*1000];
    
    RTs_dir = saccadeRTs(data,inx);
    RTs = [RTs, RTs_dir - nanmean(RTs_dir)];
end
[r,p_val] = corr(spikes',RTs','Rows','Pairwise','type','Spearman');

end