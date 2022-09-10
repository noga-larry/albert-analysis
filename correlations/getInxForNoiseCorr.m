function inx_cell = getInxForNoiseCorr(data,epoch)

PROBABILITIES = [25,75];
DIRECTIONS = 0:45:315;

[~,match_p] = getProbabilities (data);
[~,match_d] = getDirections (data);

boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

switch epoch
            case 'cue'
                inx_cell = cell(1,length(PROBABILITIES));
                for j=1:length(PROBABILITIES)
                    inx_cell{j} = find (match_p == PROBABILITIES(j) & (~boolFail));
                end
            case 'targetMovementOnset'
                inx_cell = cell(1,length(PROBABILITIES)*length(DIRECTIONS));
                c_inx = 0;
                for j=1:length(PROBABILITIES)
                    for k=1:length(DIRECTIONS)
                        c_inx = c_inx+1;
                        inx_cell{c_inx} = find (match_d == DIRECTIONS(k) & ...
                            match_p == PROBABILITIES(j) & (~boolFail));
                    end
                end
        end

end

