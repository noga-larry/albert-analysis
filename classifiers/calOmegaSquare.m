function [omega, tbl ] = calOmegaSquare(response,labels,label_names, varargin)

p = inputParser;

defaultPartial = false;
addOptional(p,'partial',defaultPartial,@islogical);

defaultSstype = 2;
addOptional(p,'sstype',defaultSstype,@isnumeric);

defaultIncludeTime = true;
addOptional(p,'includeTime',defaultIncludeTime,@islogical);

defaultModel = 'full';
addOptional(p,'model',defaultModel,@ischar);

parse(p,varargin{:})
partial = p.Results.partial;
includeTime = p.Results.includeTime;
model = p.Results.model;
sstype = p.Results.sstype;

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

[~,tbl,~,~] = anovan(response(:),groups,'varnames',label_names,'model',model,'display','off','sstype',sstype);
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
    not_inter_inx = [];
    for i = 1:length(groups)
        inx1 = find(strcmp(tbl(:,1),label_names{i}));
        inx2 = find(strcmp(tbl(:,1),['time*' label_names{i}]));        
        c = c+1;
        omega(c).value = omegafun(tbl,[inx1 inx2]);
        omega(c).variable = tbl{inx1,1};
        not_inter_inx = [not_inter_inx inx1 inx2];
    end
    
    c=c+1;
    inx1 = find(strcmp(tbl(:,1),'reward probability*reward outcome'));
    inx2 = find(strcmp(tbl(:,1),'time*reward probability*reward outcome'));
    
     
    if ~isempty(inx1)||~isempty(inx2)
        omega(c).variable = 'prediction_error';
        omega(c).value = omegafun(tbl,[inx1 inx2]);
        c=c+1;
    end
    
    inx = setdiff(2:(length(tbl)-2),not_inter_inx);
    omega(c).variable = 'Interactions';
    omega(c).value = omegafun(tbl,inx);
    
    % time and interactions with time
    inx = find(contains(tbl(:,1),'time'));
    omega(c).variable = 'time_and_interactions_with_time';
    omega(c).value = omegafun(tbl,inx);
else
    c=0;
    for i = 1:length(groups)
        c = c+1;
        omega(c).value = omegafun(tbl,i+1);
        omega(c).variable = tbl{i+1,1};
    end
    if any(strcmp(tbl(:,1),'reward probability*reward outcome'))
        inx = find(strcmp(tbl(:,1),'reward probability*reward outcome'));
        omega(c+1).value = omegafun(tbl,inx);
        omega(c+1).variable = 'prediction error';
        c = c+1;
    end
    if length(groups)>1 % more than one group
        omega(c+1).variable = 'Interactions';
        omega(c+1).value = omegafun(tbl,[(length(groups)+2):(size(tbl,1)-2)]);
    end
end



%omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);

