clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("pursuit");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

EPOCHS = {'targetMovementOnset','targetMovementOnset'};

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;

    effects1(ii) = effectSizeInEpoch(data,EPOCHS{1});
    effects2(ii) = effectSizeInEpoch(data,EPOCHS{2},...
        'velocityInsteadReward',true);
end

%%
figure;

N = length(req_params.cell_type);
figure;


for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));

    subplot(2,N,i)
    scatter(omegaT(1,indType),omegaT(2,indType),'filled');
    [r,p] = corr(omegaT(1,indType)',omegaT(2,indType)','type','Spearman','Rows','Pairwise');
    title(['time , r = ' num2str(r) ', p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('outcome')
    ylabel('cue')
    equalAxis()
    refline(1,0)

    subplot(2,N,N+i)
    scatter(omegaO(1,indType),omegaO(2,indType),'filled');
    [r,p] = corr(omegaO(1,indType)',omegaO(2,indType)','type','Spearman','Rows','Pairwise');
    title(['reward , r = ' num2str(r) ', p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('outcome')
    ylabel('cue')
    equalAxis()
    refline(1,0)
end

%% scatters

figure;
N = length(req_params.cell_type);
f = fields(effects1);

c=1;
for j = 1:length(f)
    for i = 1:N

        subplot(length(f),N,c)
        indType = find(strcmp(req_params.cell_type{i}, cellType));

        scatter([effects1(indType).(f{j})],[effects2(indType).(f{j})],'filled','k'); hold on
        p = signrank([effects1(indType).(f{j})],[effects2(indType).(f{j})]);
  
        subtitle(['p = ' num2str(p)])
        equalAxis()
        refline(1,0)

        xlabel(EPOCHS{1})
        ylabel(EPOCHS{2})

        title([f{j} ': ' req_params.cell_type{i}])

        c=c+1;
    end
end

%%
figure;
N = length(req_params.cell_type);
f = fields(effects1);

c=1;

for i = 1:N

    subplot(2,ceil(N/2),c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    scatter([effects1(indType).reward_probability],[effects2(indType).velocity],'filled','k'); hold on
    p = signrank([effects1(indType).reward_probability],[effects2(indType).velocity]);

    subtitle(['p = ' num2str(p)])
    equalAxis()
    refline(1,0)

    xlabel('reward')
    ylabel('velocity')

    title(req_params.cell_type{i})

    c=c+1;
end
