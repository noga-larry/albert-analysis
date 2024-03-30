

function [omega, tbl, pVals] = calOmegaSquare(response, labels, label_names, varargin)
% calOmegaSquare - Calculate omega squared effect size over the entire epoch or as a function of time.
%
% Syntax:
%   [omega, tbl, pVals] = calOmegaSquare(response, labels, labelNames, varargin)
%
% Inputs:
%   response - Matrix with the responses of neurons in different conditions.
%              The size should be TxN, where T is the number of time bins
%              and N is the number of trials.
%   labels - Cell array in which each element is a vector with the condition
%            on trial t corresponding to the t column in response.
%   label_names - Cell array of strings with the names of the variable in 
%                labels.
% Optional Inputs:
%   'partial' - A logical indicating whether to calculate partial omega
%               squared (default: true).
%   'sstype' - An integer indicating the sum of squares type for ANOVA 
%              (default: 2).
%   'includeTime' - A logical indicating whether to include time in the 
%               analysis (default: true, i.e, one number for entire epoch).
%   'model' - A character vector specifying the ANOVA model (default: 
%             'full').
%
% Outputs:
%   omega - Structure containing omega squared effect sizes.
%   tbl - ANOVA table.
%   pVals - p-values corresponding to omega squared effect sizes.

p = inputParser;

defaultPartial = true;
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
    labels_for_model{1} = repmat((1:size(response,1))',1,size(response,2));
    label_names_for_model = {'time', label_names{:}};
    c = 1;
else
    c=0;
    label_names_for_model = label_names;
end
for i = 1:length(labels)
    labels_for_model{i+c} = repmat(labels{i},size(response,1),1);

end
for i = 1:length(labels_for_model)
    tmp = labels_for_model{i};
    labels_for_model{i} = tmp(:);
end

[~,tbl,~,~] = anovan(response(:),labels_for_model,'varnames',label_names_for_model,'model',model,'display','off','sstype',sstype);
%ss = sumsOfSquares(response(:),{groupT(:),groupR(:)});

%     ss_error(ii,1) = tbl{5,2};ss_error(ii,2) = ss.error;
%     ss_a(ii,1) = tbl{2,2};ss_a(ii,2) = ss.X1;
%     ss_b(ii,1) = tbl{3,2};ss_b(ii,2) = ss.X2;
%     ss_ab(ii,1) = tbl{4,2};ss_ab(ii,2) = ss.interaction;


totVar = tbl{end,2};
msw = tbl{end-1,5};
N = length(response(:));

% Define function
if partial
    %     omegafun = @(tbl,dim) (tbl{dim,3}*(tbl{dim,5}-msw))/...
    %         (tbl{dim,3}*tbl{dim,5}+(N-tbl{dim,3})*msw);
    omegafun = @(tbl,dim) (sum([tbl{dim,2}])-(sum([tbl{dim,3}])*msw))/...
        (sum([tbl{dim,2}])+(N-sum([tbl{dim,3}]))*msw);
    
else
    omegafun = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
end

% pVals
pValFun = @(tbl,dim) 1-fcdf((sum([tbl{dim,2}])/sum([tbl{dim,3}]))/msw...
    ,sum([tbl{dim,3}]),tbl{end-1,3});

omega = creatingOutputStructure(tbl,labels_for_model,omegafun,label_names_for_model,includeTime);

pVals = creatingOutputStructure(tbl,labels_for_model,pValFun,label_names_for_model,includeTime);

end


function outputStruct = creatingOutputStructure(tbl,groups,func,...
    labelNames,includeTime)

if includeTime
    c=0;
    not_inter_inx = [];
    for i = 1:length(groups)
        inx1 = find(strcmp(tbl(:,1),labelNames{i}));
        inx2 = find(strcmp(tbl(:,1),['time*' labelNames{i}]));
        c = c+1;
        outputStruct(c).value = func(tbl,[inx1 inx2]);
        outputStruct(c).variable = tbl{inx1,1};
        not_inter_inx = [not_inter_inx inx1 inx2];
    end
    
    c=c+1;
    inx1 = find(strcmp(tbl(:,1),'reward_probability*reward_outcome'));
    inx2 = find(strcmp(tbl(:,1),'time*reward_probability*reward_outcome'));
    
    
    if ~isempty(inx1)||~isempty(inx2)
        outputStruct(c).variable = 'prediction_error';
        outputStruct(c).value = func(tbl,[inx1 inx2]);
        c=c+1;
    end
    
    inx = setdiff(2:(size(tbl,1)-2),not_inter_inx);
    outputStruct(c).variable = 'Interactions';
    outputStruct(c).value = func(tbl,inx);
    c=c+1;

    % time and interactions with time
    inx = find(contains(tbl(:,1),'time'));
    outputStruct(c).variable = 'time_and_interactions_with_time';
    outputStruct(c).value = func(tbl,inx);
else
    c=0;
    for i = 1:length(groups)
        c = c+1;
        outputStruct(c).value = func(tbl,i+1);
        outputStruct(c).variable = tbl{i+1,1};
    end
    if any(strcmp(tbl(:,1),'reward_probability*reward_outcome'))
        inx = find(strcmp(tbl(:,1),'reward_probability*reward_outcome'));
        outputStruct(c+1).value = func(tbl,inx);
        outputStruct(c+1).variable = 'prediction_error';
        c = c+1;
    end
    if length(groups)>1 % more than one group
        outputStruct(c+1).variable = 'Interactions';
        outputStruct(c+1).value = func(tbl,[(length(groups)+2):(size(tbl,1)-2)]);
    end
end
end



