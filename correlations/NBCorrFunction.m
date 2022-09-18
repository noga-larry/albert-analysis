function [nb_corr,nb_significance] = NBCorrFunction(data, probabilities,...
    directions,raster_params, bin_sz, task, varargin)

p = inputParser;
defaultShiftControl = false;
defaultPlotZScores = false;
addOptional(p,'shiftControl',defaultShiftControl,@islogical);
addOptional(p,'plotZScore',defaultPlotZScores,@islogical);
parse(p,varargin{:})
shiftControl = p.Results.shiftControl;
plotZScores = p.Results.plotZScore;


behavior_params.time_after = 250;
behavior_params.time_before = -100;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

[~,match_p] = getProbabilities (data);
boolFail = [data.trials.fail] | ~[data.trials.previous_completed];



for p=1:length(probabilities)

    inx_prob = find(match_p==probabilities(p) & ~ boolFail);
    [~,match_d] = getDirections (data,inx_prob,'omitNonIndexed',true);


    if task == "pursuit_8_dir_75and25"
        [~,~,H,~] = meanVelocitiesRotated(data,behavior_params,inx_prob);
        behavior = mean(H,2,"omitnan");

    elseif task == "saccade_8_dir_75and25"
        behavior = saccadeRTs(data,inx_prob);
    end

    psths= getSTpsth(data,inx_prob,raster_params);
    psths = downSampleToBins(psths,bin_sz);

    for d = 1:length(directions)
        inx = find(match_d==directions(d));
        behavior(inx) = behavior(inx) - mean(behavior(inx),"omitnan");
    end

    if plotZScores
        subplot(length(probabilities),1,p); hold off
        plot(zscore(behavior)); hold on
        plot(zscore(mean(psths,2)))
        legend('behavior','rate')
    end

    if shiftControl
        behavior = behavior(1:end-1);
        psths = psths(2:end,:);
    end

    [r,p_val] = corr(psths,behavior',rows="pairwise");
    nb_corr(p,:) = r;
    nb_significance(p,:)= p_val;

end

if plotZScores
    sgtitle([data.info.trial_type ' - ' num2str(data.info.cell_ID)])
    pause
end