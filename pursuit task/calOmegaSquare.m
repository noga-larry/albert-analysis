function omega = calOmegaSquare(response,labels)

groups{1} = repmat((1:size(response,1))',1,size(response,2));
for i = 1:length(labels)
    groups{i+1} = repmat(labels{i},size(response,1),1);
end
for i = 1:length(groups)
    tmp = groups{i};
    groups{i} = tmp(:);
end

[~,tbl,~,~] = anovan(response(:),groups,'model','interaction','display','off');
%ss = sumsOfSquares(response(:),{groupT(:),groupR(:)});

%     ss_error(ii,1) = tbl{5,2};ss_error(ii,2) = ss.error;
%     ss_a(ii,1) = tbl{2,2};ss_a(ii,2) = ss.X1;
%     ss_b(ii,1) = tbl{3,2};ss_b(ii,2) = ss.X2;
%     ss_ab(ii,1) = tbl{4,2};ss_ab(ii,2) = ss.interaction;
totVar = tbl{end,2};
msw = tbl{end-1,5};
SSe = tbl{end-1,2};
N = length(response(:));

omegafun = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
c=0;
for i = 2:(length(tbl)-3)
    c = c+1;
    omega(c).value = omegafun(tbl,i);
    omega(c).variable = tbl{i,1};
end
omega(c+1).variable = 'Total';
omega(c+1).value = (totVar - SSe)/totVar;
%omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);

