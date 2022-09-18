function [nn_corr,nn_sig] = NnCorrFunction(data1, data2,...
    raster_params, bin_sz, varargin)

DIRECTIONS = 0:45:315;
PROBABILIES = [25,75];
OUTCOMES = [0,1];

p = inputParser;
defaultShiftControl = false;
defaultSeperateByPrev = false;
addOptional(p,'shiftControl',defaultShiftControl,@islogical);
addOptional(p,'seperateByPrev',defaultSeperateByPrev,@islogical);
parse(p,varargin{:})
shiftControl = p.Results.shiftControl;
seperateByPrev = p.Results.seperateByPrev;
[data1,data2] = reduceToSharedTrials(data1,data2);

boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];

[~,match_p] = getProbabilities(data1);
for p = 1:length(PROBABILIES)
    inx = find(match_p==PROBABILIES(p) & ~ boolFail);
    psth1 = getSTpsth(data1,inx,raster_params);
    psth2 = getSTpsth(data2,inx,raster_params);

    psth1 = downSampleToBins(psth1, bin_sz);
    psth2 = downSampleToBins(psth2, bin_sz);

    if shiftControl
        psth1 = psth1(1:end-1,:); psth2 = psth2(2:end,:);
    end

    [corr_mat,p_val] = corr(psth1,psth2);

    nn_corr(p,:) = diag(corr_mat);
    nn_sig(p,:) = diag(p_val)<0.05;

    end
end