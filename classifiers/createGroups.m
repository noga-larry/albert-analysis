
function groups = createGroups(data,epoch,ind,prev_out)

PROBABILITIES = 0:25:100;

if strcmp(data.info.task,'rwd_direction_tuning') % FLOCCULUS TASK!
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [~,match_p] = getRewardSize (data,ind,'omitNonIndexed',true);
elseif strcmp(data.info.task,'choice')
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_d = match_d(1,:);
else
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
end

match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
[match_o] = getOutcome (data,ind,'omitNonIndexed',true);

switch epoch
    
    case 'cue'
        if strcmp(data.info.task,'choice')
            groups = {match_d,match_p};
        else
            groups = {match_p};
        end
    case 'targetMovementOnset'
        groups = {match_d,match_p};
        
    case 'reward'
        groups = {match_p,match_d,match_o};
end

if prev_out
    groups{end+1} =  match_po;
end


end
