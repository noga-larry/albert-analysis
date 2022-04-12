function omega = calOmegaSquare(response,labels,varargin)

p = inputParser;

defaultPartial = false;
addOptional(p,'partial',defaultPartial,@islogical);

defaultIncludeTime = true;
addOptional(p,'includeTime',defaultIncludeTime,@islogical);

defaultModel = 'interaction';
addOptional(p,'model',defaultModel,@ischar);

parse(p,varargin{:})
partial = p.Results.partial;
includeTime = p.Results.includeTime;
model = p.Results.model;

if includeTime
    groups{1} = repmat((1:size(response,1))',1,size(response,2));
    c = 1;
else
    c=0;
end
for i = 1:length(labels)
    groups{i+c} = repmat(labels{i},size(response,1),1);
end
for i = 1:length(groups)
    tmp = groups{i};
    groups{i} = tmp(:);
end

[~,tbl,~,~] = anovan(response(:),groups,'model',model,'display','off');
%ss = sumsOfSquares(response(:),{groupT(:),groupR(:)});

%     ss_error(ii,1) = tbl{5,2};ss_error(ii,2) = ss.error;
%     ss_a(ii,1) = tbl{2,2};ss_a(ii,2) = ss.X1;
%     ss_b(ii,1) = tbl{3,2};ss_b(ii,2) = ss.X2;
%     ss_ab(ii,1) = tbl{4,2};ss_ab(ii,2) = ss.interaction;
totVar = tbl{end,2};
msw = tbl{end-1,5};
SSe = tbl{end-1,2};
N = length(response(:));

if partial
%     omegafun = @(tbl,dim) (tbl{dim,3}*(tbl{dim,5}-msw))/...
%         (tbl{dim,3}*tbl{dim,5}+(N-tbl{dim,3})*msw);
    omegafun = @(tbl,dim) (sum([tbl{dim,2}])-(sum([tbl{dim,3}])*msw))/...
        (sum([tbl{dim,2}])+(N-sum([tbl{dim,3}]))*msw);

else
    omegafun = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
end

if includeTime
    c=0;
    for i = 1:length(groups)
        inx1 = find(strcmp({tbl{:,1}},['X' num2str(i)]));
        inx2 = find(strcmp({tbl{:,1}},['X1*X' num2str(i)]));        
        c = c+1;
        omega(c).value = omegafun(tbl,[inx1 inx2]);
        omega(c).variable = tbl{inx1,1};
    end
    omega(c+1).variable = 'Total';
    omega(c+1).value = (totVar - SSe)/totVar;
else
    c=0;
    for i = 1:length(groups)
        c = c+1;
        omega(c).value = omegafun(tbl,i+1);
        omega(c).variable = tbl{i+1,1};
    end
    omega(c+1).variable = 'Interactions';
    omega(c+1).value = omegafun(tbl,[(length(groups)+2):(length(tbl)-2)]);
   
end



%omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);

