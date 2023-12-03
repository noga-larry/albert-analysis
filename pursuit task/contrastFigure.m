
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'reward';
PLOT_CELL = false;


req_params = reqParamsEffectSize("both","both");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;


    [effectSizes(ii,:),ts] = contrastInTimeBin...
        (data,EPOCH,'prevOut',false,...
        'velocityInsteadReward',false);
end

%%

figure; hold on

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));

    errorbar(ts,nanmean(effectSizes(indType,:),1), nanSEM(effectSizes(indType,:)))



end
legend(req_params.cell_type)
xlabel(['time from ' EPOCH ' (ms)' ])


%%

figure; hold on

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    for t=1:length(ts)
        x = effectSizes(indType,t);
        pval(i,t) = bootstrapTTest(x)<(0.05/16/4);
    end
    
    plot(ts,pval(i,:),'*')

end
legend(req_params.cell_type)
xlabel(['time from ' EPOCH ' (ms)' ])
%%

function [effectSizes, ts, low] = contrastInTimeBin(data,epoch,varargin)

MINIMAL_RATE_IN_BIN = 0.001;

p = inputParser;

defaultPrevOut = false;
addOptional(p,'prevOut',defaultPrevOut,@islogical);
defaultVelocity = false;
addOptional(p,'velocityInsteadReward',defaultVelocity,@islogical);
defaultNumCorrectiveSaccades = false;
addOptional(p,'numCorrectiveSaccadesInsteadOfReward',defaultNumCorrectiveSaccades,@islogical);


parse(p,varargin{:})
prevOut = p.Results.prevOut;
velocityInsteadReward = p.Results.velocityInsteadReward  ;
numCorrectiveSaccadesInsteadOfReward = p.Results.numCorrectiveSaccadesInsteadOfReward;


[response,ind,ts] = data2response(data,epoch);

[groups, group_names] = createGroups(data,epoch,ind,prevOut,velocityInsteadReward,...
    numCorrectiveSaccadesInsteadOfReward);

% groups{1} = randPermute(groups{1});
% groups{3} = randPermute(groups{3});

inxForXAve = {...
    find(groups{2}==25 & groups{3}==0),...
    find(groups{2}==25 & groups{3}==1),...
    find(groups{2}==75 & groups{3}==0),...
    find(groups{2}==75 & groups{3}==1)};

contrastWeights = [1,0,-1,0];
ns = cellfun(@length,inxForXAve);

for t=1:length(ts)

    if mean(response(t,:))<MINIMAL_RATE_IN_BIN
        low = 1;
    end

    [~, tbl ] =  calOmegaSquare(response(t,:),groups, group_names,'partial',true,...
        'includeTime',false);

    msw = tbl{end-1,5};
    N = length(response(t,:));

    for i=1:length(inxForXAve)
        xAve(i) = mean(response(t,inxForXAve{i}));
    end
    ssc =(contrastWeights*xAve')^2/sum((contrastWeights.^2)./ns);
    
    % df of effect size is 1. 
    effectSizes(t) = (ssc-msw)/(ssc+(N-1)*msw);

end


end
