
function [groups, group_names] = createGroups(data,epoch,ind,...
    prevOut,velocityInsteadReward,numCorrectiveSaccadesInsteadOfReward)

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


if velocityInsteadReward
    behavior_params.time_after = 800;
    behavior_params.time_before = -400;
    behavior_params.smoothing_margins = 100; % ms
    behavior_params.SD = 15; % ms

    [~,~,vel] = meanVelocitiesRotated(data,behavior_params,...
        ind,'removeSaccades',true,'smoothIndividualTrials',true);

    meanVels = mean(vel,2,'omitnan');
    match_p = meanVels>median(meanVels,'omitnan');
end

if numCorrectiveSaccadesInsteadOfReward
    numCorrective = numCorrectiveSaccades(data,ind);
    match_p = numCorrective>median(numCorrective);
end

match_po = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
[match_o] = getOutcome (data,ind,'omitNonIndexed',true);

switch epoch
    
    case 'cue'
        if strcmp(data.info.task,'choice')
            groups = {match_d,match_p};
            group_names = {'directions','reward_probability'};
        else
            groups = {match_p};
            group_names = {'reward_probability'};
        end
    case {'targetMovementOnset','saccadeLatency','pursuitLatencyRMS'}
        groups = {match_d,match_p};
        group_names = {'directions','reward_probability'};
        
    case 'reward'
        groups = {match_p,match_d,match_o};
        group_names = {'directions','reward_probability','reward_outcome'};

    case {'targetMovementOnsetWithVelocity'}

        groups = {match_d,match_p};
        

end

if prevOut
    groups{end+1} =  match_po;
    groups{end+1} = 'previous_outcome';

end

if velocityInsteadReward
    i = find(strcmp('reward_probability',group_names));
    group_names{i} = 'velocity';
end

if numCorrectiveSaccadesInsteadOfReward
    i = find(strcmp('reward_probability',group_names));
    group_names{i} = 'num_corrective_saccades';
end

