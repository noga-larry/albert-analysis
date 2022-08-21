function p = bootstraspWelchANOVA(y, g)

REPEATS = 10000;

if iscell(g)
    g = g_cell2vec(g);
end
[~,F_true,] = wanova(y, g);

F_dist = nan(1,REPEATS);
for j=1:REPEATS    
    prm = permVec(g);
    [~,F_dist(j)] = wanova(y,prm);
end

p = mean(F_dist>F_true);

end

function g = g_cell2vec(g)
    g_cell=g;
    unique_g = uniqueRowsCA(g);
    g = nan(size(g));
    for i=1:length(unique_g)
        inx = find(strcmp(g_cell,unique_g{i}));
        g(inx)=i;
    end
end