function num = numCorrectiveSaccades(data,ind)
% Calculated the number of corrective saccades in the ind trials in a
% purstuit task. 

targetMotionOnset = alignmentTimesFactory(data,ind,'targetMovementOnset');
targetMotionOffset = alignmentTimesFactory(data,ind,'targetMovementOffset');

num = nan(1,length(ind));

for i=1:length(ind)
    t = data.trials(ind(i)).beginSaccade;
    num(i) = sum(t>targetMotionOnset(i) & t<targetMotionOffset(i));
end
end