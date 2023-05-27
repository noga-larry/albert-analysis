clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
%req_params.cell_type = {'SNR'};

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

EPOCHS = {'targetMovementOnset','cue'};

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
        p_sign = bootstraspWelchTTest([effects1(indType).(f{j})],[effects2(indType).(f{j})]);
        [r,p_comp] = corr([effects1(indType).(f{j})]',[effects2(indType).(f{j})]',type="Spearman");
        title({[f{j} ': ' req_params.cell_type{i} '- signrank p = '], [num2str(p_sign,2)...
        ' , Spearman: r = ' num2str(r,2) ', p =' num2str(p_comp,2)]},'FontSize',8)
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
f1 = 'directions';
f2 = 'reward_probability';
c=1;

for i = 1:N

    subplot(2,ceil(N/2),c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    scatter([effects1(indType).(f1)],[effects2(indType).(f2)],'filled','k'); hold on
    p_comp = bootstraspWelchTTest([effects1(indType).(f1)],[effects2(indType).(f2)]);
    [r,p] = corr([effects1(indType).(f1)]',[effects2(indType).(f2)]',type="Spearman");
    %% 


    title(['bootstraspWelchTTest - p = ' num2str(p_comp)])
    subtitle(['Spearman: r = ' num2str(r) ', p = ' num2str(p)])
    equalAxis()
    refline(1,0)

    xlabel(f1,'Interpreter','none')
    ylabel(f2,'Interpreter','none')

    title([req_params.cell_type{i}])

    c=c+1;
    disp([req_params.cell_type{i} ': ' num2str(signrank([effects1(indType).(f1)]))])
    
end
