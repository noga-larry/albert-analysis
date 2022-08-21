function p = bootstraspWelchTTest(x, y)

REPEATS = 10000;

scores = [x,y];
labels = [zeros(size(x)),ones(size(y))];

t_real = statistic(scores,labels);

t_dist = nan(1,REPEATS);
for j=1:REPEATS    
    prm = permVec(labels);
    t_dist(j) = statistic(scores,prm);
end

p = mean(abs(t_dist)>abs(t_real));

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

function g = g_boolian(g)
    g_cell=g;
    unique_g = unique(g);
    g = nan(size(g));
    for i=1:length(unique_g)
        inx = find(g_cell==unique_g(i));
        g(inx)=i;
    end
end


function t = statistic(y,g)
    
    nominator = mean(y(g==0))-mean(y(g==1));
    
    v1 = var(y(g==0)); v2 = var(y(g==1));
    n1 = sum(g==0); n2 = sum(g==1); 
    demonimator = sqrt(v1/n1+v2/n2);
    
    t = nominator/demonimator;
    
end