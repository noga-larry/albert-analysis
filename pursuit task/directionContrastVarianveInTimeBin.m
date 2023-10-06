
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECTIONS = 0:45:315;


req_params = reqParamsEffectSize("saccade");
%req_params.ID = [4797];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);


contrastSTD = nan(length(cells),32);

c = 1;
for ii = 1:length(cells)

    if mod(ii,100)==0
        disp([num2str(ii) '/' num2str(length(cells))])
    end

    data = importdata(cells{ii});



    for d=1:length(DIRECTIONS)
        [contrast(d,:)] = contrastInTimeBin(data,EPOCH,DIRECTIONS(d));


    end

    contrastSTD(ii,:) = std(contrast);

    a = effectSizeInTimeBin...
        (data,EPOCH,'prevOut',false,...
        'velocityInsteadReward',false);

    effectSize(ii,:) = [a.directions];
    
    cellType{c} = task_info(lines(ii)).cell_type;
    cellID(c) = data.info.cell_ID;
    c=c+1;
end

%%

N = length(req_params.cell_type);

for ii = 1:N

    subplot(1,N,ii)


    indType = find(strcmp(req_params.cell_type{ii}, cellType));
    scatter(effectSize(indType),contrastSTD(indType),'filled','k'); hold on
    [r,p] = corr(effectSize(indType),contrastSTD(indType),'type','Spearman','rows','pairwise');
    ylabel('contrast STD')
    xlabel('direction effect size')
    title([req_params.cell_type{ii}, ': r= ' num2str(r) ', p = ' num2str(p)], 'Interpreter','none')
end


%%

figure;

gscatter([effectSize(:)],[contrastSTD(:)],cellType(:))
%%

NUM_RANKS = 20;


for ii = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{ii}, cellType));
    
    ranks = quantileranks(EffectSize(indType),NUM_RANKS);
    unique_ranks = unique(ranks);
    
    for j=1:length(unique_ranks)
        
        inx = indType(find(ranks == j));
        
        ave_effect(j) = mean([effects(inx).(fld)]);
        x=latency(inx,:,:);
        
        ave_latency(j) = mean(x(:),'all','omitnan');
        sem_latency(j) = nanSEM(x(:));
        %         ave_latency(j) = median(x(:),'all','omitnan');
        %         if ~isnan(ave_latency(j))
        %             ci = bootci(1000,@(x) median(x,'omitnan'),x(:));
        %         else
        %             ci = [nan nan];
        %         end
        %         pos(j) = ci(1); neg(j) = ci(2);
        
        n(ii,j) = sum(~isnan(x(:)));
    end
    %errorbar(ave_effect,ave_latency,neg,pos)
    errorbar(ave_effect,ave_latency,sem_latency)
    xlabel(['mean effect size : ' fld],'interpreter','none')
    ylabel('mean latency')
end

sgtitle(req_params.task,'Interpreter' ,'none')
legend(req_params.cell_type)



%%
function [effectSizes, ts, low] = contrastInTimeBin(data,epoch,direc,varargin)

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

inxForXAve = {...
    find(groups{1}==direc),...
    find(groups{1}~=direc)};
   
contrastWeights = [1,-1];
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

