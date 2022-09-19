function [nb_corr,nb_significance] = NBCorrFunction(data,...
    raster_params, bin_sz, task, varargin)

DIRECTIONS = 0:45:315;
PROBABILIES = [25,75];
OUTCOMES = [0,1];

ii = inputParser;
defaultShiftControl = false;
defaultPlotZScores = false;
defaultSeperateByPrev = false;
addOptional(ii,'shiftControl',defaultShiftControl,@islogical);
addOptional(ii,'plotZScore',defaultPlotZScores,@islogical);
addOptional(ii,'seperateByPrev',defaultSeperateByPrev,@islogical);
parse(ii,varargin{:})
shiftControl = ii.Results.shiftControl;
plotZScores = ii.Results.plotZScore;
seperateByPrev = ii.Results.seperateByPrev;

behavior_params.time_after = 250;
behavior_params.time_before = -100;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

[~,match_p] = getProbabilities (data);
[match_o] = getPreviousOutcomes (data);
boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

if seperateByPrev
    inx_cond = cell(length(PROBABILIES)*length(OUTCOMES),1);
    c = 0;
    for p = 1:length(PROBABILIES)
        for ii=1:length(OUTCOMES)
            c = c+1;
            inx_cond{c} = find(match_p==PROBABILIES(p) & ...
                match_o==OUTCOMES(ii) & ~ boolFail);
        end
    end
else
    c = 0;
    inx_cond = cell(length(PROBABILIES),1);
    for p = 1:length(PROBABILIES)
        c = c+1;
        inx_cond{c} = find(match_p==PROBABILIES(p) & ~ boolFail);
    end
end

for ii=1:length(inx_cond)


    [~,match_d] = getDirections (data,inx_cond{ii},'omitNonIndexed',true);


    if task == "pursuit_8_dir_75and25"
        [~,~,H,~] = meanVelocitiesRotated(data,behavior_params,inx_cond{ii});
        behavior = mean(H,2,"omitnan");

    elseif task == "saccade_8_dir_75and25"
        behavior = saccadeRTs(data,inx_cond{ii})';
    end

    psths = getSTpsth(data,inx_cond{ii},raster_params);
    psths = downSampleToBins(psths,bin_sz);

    for d = 1:length(DIRECTIONS)
        inx = find(match_d==DIRECTIONS(d));
        behavior(inx) = behavior(inx) - mean(behavior(inx),"omitnan");
    end

    if plotZScores
        subplot(length(probabilities),1,ii); hold off
        plot(zscore(behavior)); hold on
        plot(zscore(mean(psths,2)))
        legend('behavior','rate')
    end

    if shiftControl
        behavior = behavior(1:end-1);
        psths = psths(2:end,:);
    end

    [r,p_val] = corr(psths,behavior,rows="pairwise");
    nb_corr(ii,:) = r;
    nb_significance(ii,:)= p_val;

end

if plotZScores
    sgtitle([data.info.trial_type ' - ' num2str(data.info.cell_ID)])
    pause
end