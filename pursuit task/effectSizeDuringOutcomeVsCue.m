clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("pursuit");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

EPOCHS = {'targetMovementOnset','pursuitLatencyRMS'};

for ii = 1:length(cells)

    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    cellType{ii} = task_info(lines(ii)).cell_type;

    effects1(ii) = effectSizeInEpoch(data,EPOCHS{1});
    effects2(ii) = effectSizeInEpoch(data,EPOCHS{2},...
        'velocityInsteadReward',false,...
        'numCorrectiveSaccadesInsteadOfReward',false);
end

%
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
        p_sign = signrank([effects1(indType).(f{j})],[effects2(indType).(f{j})]);
        [r,p] = corr([effects1(indType).(f{j})]',[effects2(indType).(f{j})]',type="Spearman");
        title({[f{j} ': ' req_params.cell_type{i} '- signrank p = '], [num2str(p_sign,2)...
        ' , Spearman: r = ' num2str(r,2) ', p =' num2str(p,2)]},'FontSize',8)
        equalAxis()
        refline(1,0)

        xlabel(EPOCHS{1})
        ylabel(EPOCHS{2})

        c=c+1;
    end
end

%%
figure;
N = length(req_params.cell_type);
f1 = 'reward_probability';
f2 = 'velocity';
c=1;

for i = 1:N

    subplot(2,ceil(N/2),c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    scatter([effects1(indType).(f1)],[effects2(indType).(f2)],'filled','k'); hold on
    p = signrank([effects1(indType).(f1)],[effects2(indType).(f2)]);

    subtitle(['p = ' num2str(p)])
    equalAxis()
    refline(1,0)

    xlabel(f1,'Interpreter','none')
    ylabel(f2,'Interpreter','none')

    title([req_params.cell_type{i}])

    c=c+1;
    disp([req_params.cell_type{i} ': ' num2str(signrank([effects1(indType).(f1)]))])
    
end
