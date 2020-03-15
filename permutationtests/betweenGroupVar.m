function stat = betweenGroupVar(smpl,match)
groups = unique(match,'rows');
for i=1:length(groups)
    if size(match,2)==1
        aves(i,:) = mean(var(smpl(match==groups(i),:)));
    else
        ind = find(sum(match==groups(i,:),2) == size(match,2));
        aves(i,:) = mean(smpl(ind,:));
    end
    stat = mean(aves);
    
end