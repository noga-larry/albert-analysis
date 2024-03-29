clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
TIME_BEFORE = 0;
TIME_AFTER = 800;
FEILD = 'directions';

req_params = reqParamsEffectSize("both");
req_params.cell_type = {'CRB'};
req_params.remove_question_marks = true;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    
    boolFail = [data.trials.fail];
    
    effectsEpoch(ii) = effectSizeInEpoch(data,EPOCH);
    [effectsTime(ii,:),ts] = effectSizeInTimeBin...
        (data,EPOCH,'prevOut',false);

    CV2(ii) = getCV2(data,find(~boolFail),'cue',TIME_BEFORE,TIME_AFTER);
    FR(ii) = getFR(data,find(~boolFail),'cue',TIME_BEFORE,TIME_AFTER);
    CV(ii) = getCV(data,find(~boolFail),'cue',TIME_BEFORE,TIME_AFTER);
    
    if ~isempty(task_info(lines(ii)).waveform_width)
        WFW(ii) = task_info(lines(ii)).waveform_width;
    else
        WFW(ii) = nan;
    end
end

%%
figure
subplot(3,1,1)
gscatter(CV2,FR,cellType')
ylabel('FR'); xlabel('CV2')

subplot(3,1,2)
gscatter(CV,FR,cellType')
ylabel('FR'); xlabel('CV')


subplot(3,1,2)
gscatter(WFW,FR,cellType')
ylabel('FR'); xlabel('Waveform')


figure;

plot3(FR,CV,WFW,'*')

xlabel('FR')
ylabel('CV')
zlabel('WFW')

%% PCA for CRB

X = [WFW',FR',CV'];
X = nanzscore(X);
[coeff,scores,latent,tsquared,explained,mu] = pca(X);



figure
subplot(2,1,1)
scatter(scores(:,1),scores(:,2))
xlabel('PC 1'); ylabel('PC 2')
subplot(2,1,2)
plot(cumsum(explained))
%% corr with score
figure
scatter(scores(:,1),[effectsEpoch.(FEILD)])
xlabel('PC score');  ylabel('Effect size')
[r,p] = corr(scores(:,1),[effectsEpoch.(FEILD)]',...
    'type','spearman','rows','pairwise');
title(['Spearman: r = ' num2str(r) ', p = ' num2str(p) ',n = ' num2str(sum(~isnan(scores(:,1))))])

%% clustering

K=2;

col = ['b','r'];
idx = kmeans(X,K);


figure
subplot(2,2,1)
gscatter(X(:,1),X(:,2),idx',col)
xlabel('normalized FR'); ylabel('normalized CV')

subplot(2,2,2)
gscatter(FR,CV,idx,col)
xlabel('FR'); ylabel('CV')


flds = fields(effectsTime);
c=1;
for f = 1:length(flds)

    subplot(2,2*length(flds),2*length(flds)+c); hold on

    for i=1:K
        a = reshape([effectsTime(find(idx==i),:).(flds{f})],...
            length(find(idx==i)),length(ts));

        errorbar(ts,nanmean(a,1), nanSEM(a,1),col(i))
    end
    title([flds{f} ], 'Interpreter', 'none')
    xlabel(['Time from ' EPOCH ])
    ylabel('effect size')
    
    c=c+1;

    subplot(2,2*length(flds),2*length(flds)+c); hold on

    for i=1:K
        plotHistForFC([effectsEpoch(find(idx==i)).(flds{f})]...
            ,-0.1:0.1:1,col(i))
    end
    title([flds{f} ], 'Interpreter', 'none')
    ylabel('Frac')
    xlabel('effect size')

    c=c+1;
end

%% 3d plot

figure; 
view(3)
grid on
hold on

idx = kmeans(X,K);

for i=1:K
    plot3(X(find(idx==i),1),X(find(idx==i),2),[effectsEpoch(find(idx==i)).(FEILD)],[col(i) 'o'])
end
% Label the axes
xlabel('FR')
ylabel('CV')
zlabel('Effect size')


%%

figure
plot3(WFW,FR,[effectsEpoch.(FEILD)],'*')

% Label the axes
xlabel('WF')
ylabel('FR')
zlabel('Effect size')

tbl = table(WFW',FR',[effectsEpoch.(FEILD)]', ...
    'VariableNames',{'WFW','FR','EF'});

mdl = fitlm(tbl,'EF ~ 1 + WFW + FR + FR*WFW')
bx = nanmedian(WFW);
by = nanmedian(FR);


for i=1:length(effectsEpoch)
    
    if WFW(i)<=bx & FR(i)<=by
        group(i) = 1;
    elseif  WFW(i)<=bx & FR(i)>by
        group(i) = 2;
    elseif  WFW(i)>bx & FR(i)<=by
        group(i) = 3;
    elseif  WFW(i)>bx & FR(i)>by
        group(i) = 4;
        
    else
        group(i) = nan;
    end
        
end


M = nan(2);
for i = 1:numel(M)
    M(i) = mean([effectsEpoch(group==i).(FEILD)])
end

p = bootstraspWelchANOVA([effectsEpoch.(FEILD)]',group')

figure; imagesc(M); colorbar
yticks([1 2]); yticklabels({'Below FR median', 'Above FR median'})
xticks([1 2]); xticklabels({'Below WFW median', 'Above WFW median'})

title(['Anova p val = ' num2str(p) ])

%% regression

X = [log(FR);log(WFW);log(WFW).*log(FR)];
mdl = fitlm(X',[effectsEpoch.(FEILD)])
mdl.Coefficients
%%

% Define bin edges based on x and y
numBins = 3;
xBinEdges = linspace(min(FR), max(FR), numBins+1);
yBinEdges = linspace(min(WFW), max(WFW), numBins+1);

% Preallocate matrix M
M = zeros(numBins, numBins);

% Iterate over each bin and calculate the mean of z values in that bin
for i = 1:numBins
    for j = 1:numBins
        % Find indices of elements in bin i,j
        binIndices = find(FR >= xBinEdges(i) & FR < xBinEdges(i+1) & ...
                          WFW >= yBinEdges(j) & WFW < yBinEdges(j+1));
        
        % Calculate mean of z values in that bin
        M(i,j) = mean([effectsEpoch(binIndices).(FEILD)],'omitnan');
    end
end

% Display resulting matrix M
figure; imagesc(M); colorbar


figure
scatter(FR, WFW/1000, [],[effectsEpoch.(FEILD)] , 'filled');
xlabel('FR')
ylabel('wavefrom - ms')
colormap parula; colorbar