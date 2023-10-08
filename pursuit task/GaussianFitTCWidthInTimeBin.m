
clear; clc;

opts = optimset('Display','off');
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECTIONS = 0:45:315;


req_params = reqParamsEffectSize("saccade");
%req_params.ID = [4797];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

% func = @(b,x) ...
%     b(1) + b(2)*exp(-0.5*((x-180).^2)/b(3));

%fitFunc = @(b,x)  b(1) * exp( b(2) * cosd( x - b(3) ) );

fitFunc = @(b,x) ...
    b(1) + b(2)*exp(-0.5*((x-180).^2)/b(3));

errorFunc = @(b,x,y) sum((fitFunc(b,x)-y).^2);
c = 0;

for ii = 1:length(cells)

    data = importdata(cells{ii});

    if mod(ii,100)==0
        disp([num2str(ii) '/' num2str(length(cells))])
    end

    [response,ind,ts] = data2response(data,EPOCH);

    groups = createGroups(data,EPOCH,ind,false,false,false);
    match_d = groups{1};
    tcsAllTimeBins = response2tcs(response,match_d);


    a = effectSizeInTimeBin...
        (data,EPOCH,'prevOut',false,...
        'velocityInsteadReward',false);

    
    for t=1:length(ts)

        c = c+1;

        cellType{c} = task_info(lines(ii)).cell_type;
        cellID(c) = data.info.cell_ID;

        currTc = tcsAllTimeBins(t,:);
        [pd, pdInd] = centerOfMass(currTc',DIRECTIONS);

        currTc = circshift(currTc,-pdInd+5);

        %currErrorFunc = @(b) errorFunc(b, DIRECTIONS, currTc);

       % b = fminsearch(currErrorFunc,[min(currTc),max(currTc),rand*360,pd],opts);
        
        b = lsqcurvefit(fitFunc,[min(currTc),max(currTc),...
            rand*360],DIRECTIONS,currTc,[],[],opts); 

        pred = fitFunc(b,0:360);

        ssRes =  sum((currTc - fitFunc(b,DIRECTIONS)).^2);
        ssTot = sum((currTc - mean(currTc)).^2);

        R(c) = (ssTot-ssRes)/ssTot;
        width(c) = b(2);

        assert(isreal(width(c)))
        %assert(width(c)>0 | ~ (b(3)>0 & b(3)<360))
        %assert(isnan(R(c)) || R(c)>=0)

        effectSize(c) = a(t).directions;



        if false

            plot(DIRECTIONS,currTc,'*'); hold on; plot(0:360,pred); hold off

            title(['R^2 = ' num2str(R(c)) ', width param = ' num2str(width(c)) ])

            pause

        end

    end

end


%%

figure; hold on
THRESH = 0.9;

for ii = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{ii}, cellType));
    plotHistForFC(R(indType),0:0.05:1)            
end
legend(req_params.cell_type)

h = R>THRESH;

figure; hold on


for ii = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{ii}, cellType) & h');
    plotHistForFC(width(indType),20) 
    leg{ii} = [req_params.cell_type{ii} ', n = ' num2str(length(indType))] 
end
legend(leg)


[p,tbl,stats] = kruskalwallis(width(h>THRESH),cellType(h>THRESH)) 

%%
[results,~,~,gnames] = multcompare(stats)
tbl = array2table(results,"VariableNames", ...
    ["Group","Control Group","Lower Limit","Difference","Upper Limit","P-value"])


%%

figure;

N = length(req_params.cell_type);


for ii = 1:N

    subplot(1,N,ii)


    indType = find(strcmp(req_params.cell_type{ii}, cellType) & h');
    scatter(effectSize(indType),width(indType),'filled','k'); hold on
    [r,p] = corr(effectSize(indType)',width(indType)','type','Spearman','rows','pairwise');
    ylabel('\sigma')
    xlabel('direction effect size')
    title([req_params.cell_type{ii}, ': r= ' num2str(r) ', p = ' num2str(p)], 'Interpreter','none')
end


%%

figure;
gscatter(effectSize(h),width(h),cellType(h))
[r,p] = corr(effectSize(h)',width(h)')


%%

clc

h = R>THRESH;
inx = find(h);
x = effectSize(inx);
cellTypeX = cellType(inx);

inputOutputFig(x,cellTypeX')

p = bootstraspWelchANOVA(x', cellTypeX)

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellTypeX))),...
    x(find(strcmp('PC ss', cellTypeX))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellTypeX))),...
    x(find(strcmp('CRB', cellTypeX))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellTypeX))),...
    x(find(strcmp('BG msn', cellTypeX))))
%%
function tcs = response2tcs(response,match_d)

DIRECTIONS = 0:45:315;

tcs = nan(size(response,1),length(DIRECTIONS));
for d=1:length(DIRECTIONS)
    inx = find(match_d==DIRECTIONS(d));
    tcs(:,d) = mean(response(:,inx),2);

end

end