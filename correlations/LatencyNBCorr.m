function [nb_corr,nb_significance] = LatencyNBCorr(data, probabilities, directions,raster_params, bin_sz)

[~,match_p] = getProbabilities (data);
boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

for p=1:length(probabilities)

    inx_prob = find(match_p==probabilities(p) & ~ boolFail);
    [~,match_d] = getDirections (data,inx_prob,'omitNonIndexed',true);
    
    latencies = saccadeRTs(data,inx_prob);

    behavior_params.time_after = 1000;
    behavior_params.time_before = 0;
    behavior_params.smoothing_margins = 100; % ms
    behavior_params.SD = 15; % ms

%     [~,~,H,V] = meanVelocities(data,behavior_params,inx_prob,...
%         'smoothIndividualTrials',true,'removeSaccades',false);
%     figure; hold on
% 
%     for ii = 1:length(latencies)
%         if ~isnan(latencies(ii))
%             plot(H(ii,:)); plot(V(ii,:));
%             plot(latencies(ii),H(ii,latencies(ii)),'*'); plot(latencies(ii),V(ii,latencies(ii)),'*');
%             pause
%             cla
%         end
%     end

    psths= getSTpsth(data,inx_prob,raster_params);
    psths = downSampleToBins(psths,bin_sz);

    for d = 1:length(directions)
        inx = find(match_d==directions(d));
        latencies(inx) = latencies(inx) - mean(latencies(inx),"omitnan");
    end
    
    % shuffle
%     latencies = latencies(1:end-1);
%     psths = psths(2:end,:);

    [r,p_val] = corr(psths,latencies',rows="pairwise");
    nb_corr(p,:) = r;
    nb_significance(p,:) = p_val;

end