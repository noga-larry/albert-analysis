function p = bootstrapTTest(x,y)

% https://www.youtube.com/watch?v=N4ZQQqyIf6k&ab_channel=StatQuestwithJoshStarmer

REPEATS = 10000;
t_stat = @(x) mean(x)/(std(x)/sqrt((length(x))));

if nargin==1
    scores = x;
else
    scores = x-y;
end

t_true = t_stat(scores);

scores_H0 = scores - mean(scores);
% Assume H0


t_dist = nan(1,REPEATS);

for i=1:REPEATS
    
    sample = randi([1 length(scores_H0)],[1 length(scores_H0)]);
    t_dist(i) = t_stat(scores_H0(sample));
end

p = mean(abs(t_dist)>abs(t_true));
