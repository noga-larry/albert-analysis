clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'cue';
TIME_BEFORE = 0;
TIME_AFTER = 800;

req_params = reqParamsEffectSize("both");
req_params.cell_type = {'PC ss','CRB'};
req_params.remove_question_marks = false;

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
end

%%
figure
subplot(2,1,1)
gscatter(CV2,FR,cellType')
ylabel('FR'); xlabel('CV2')

subplot(2,1,2)
gscatter(CV,FR,cellType')
ylabel('FR'); xlabel('CV')

%% PCA for CRB

inx = find(strcmp(cellType,'CRB'));
X = [zscore(FR(inx)'),(CV(inx)'-mean(CV(inx)))/std(CV(inx),'omitnan')];
[coeff,scores,latent,tsquared,explained,mu] = pca(X);

CRB_effect_epoch = effectsEpoch(inx)';
CRB_effect_time = effectsTime(inx,:);
%% corr with score
figure
scatter(scores(:,1),[CRB_effect_epoch.direction])
xlabel('PC score');  ylabel('Effect size')
[r,p] = corr(scores(:,1),[CRB_effect_epoch.direction]',...
    'type','spearman','rows','pairwise');
title(['Spearman: r = ' num2str(r) ', p = ' num2str(p) ',n = ' num2str(length(scores(:,1)'))])

%% clustering

K=2;

col = ['b','r'];
idx = kmeans(X,K);


figure
subplot(2,2,1)
gscatter(X(:,1),X(:,2),idx',col)
xlabel('normalized FR'); ylabel('normalized CV')

subplot(2,2,2)
gscatter(FR(inx),CV(inx),idx,col)
xlabel('FR'); ylabel('CV')


flds = fields(effectsTime);
c=1;
for f = 1:length(flds)

    subplot(2,2*length(flds),2*length(flds)+c); hold on

    for i=1:K
        a = reshape([CRB_effect_time(find(idx==i),:).(flds{f})],length(find(idx==i)),length(ts));

        errorbar(ts,nanmean(a,1), nanSEM(a,1),col(i))
    end
    title([flds{f} ], 'Interpreter', 'none')
    xlabel(['Time from ' EPOCH ])
    ylabel('effect size')
    
    c=c+1;

    subplot(2,2*length(flds),2*length(flds)+c); hold on

    for i=1:K
        plotHistForFC([CRB_effect_epoch(find(idx==i)).(flds{f})],-0.1:0.1:1,col(i))
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
    plot3(X(find(idx==i),1),X(find(idx==i),2),[CRB_effect_epoch(find(idx==i)).direction],[col(i) 'o'])
end
% Label the axes
xlabel('FR')
ylabel('CV')
zlabel('Effect size')