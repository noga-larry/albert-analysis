clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
%req_params.cell_type = {'SNR'};

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

EPOCHS = {'cue','targetMovementOnset'};

for ii = 1:length(cells)

    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    cellType{ii} = task_info(lines(ii)).cell_type;

    [effects1(ii),~,~,~,pVals1(ii)] = effectSizeInEpoch(data,EPOCHS{1});
    [effects2(ii),~,~,~,pVals2(ii)] = effectSizeInEpoch(data,EPOCHS{2},...
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
f1 = 'reward_probability';
f2 = 'directions';
c=1;


for i = 1:N

    subplot(2,ceil(N/2),c)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    scatter([effects1(indType).(f1)],[effects2(indType).(f2)],'filled','k'); hold on
    p_comp = bootstraspWelchTTest([effects1(indType).(f1)],[effects2(indType).(f2)]);
    [r,p] = corr([effects1(indType).(f1)]',[effects2(indType).(f2)]',type="Spearman");
    [r,p] = distcorr([effects1(indType).(f1)]',[effects2(indType).(f2)]')

    title([req_params.cell_type{i} ': bootstraspWelchTTest - p = ' num2str(p_comp)])
    subtitle(['Spearman: r = ' num2str(r) ', p = ' num2str(p)])
    equalAxis()
    refline(1,0)

    xlabel([EPOCHS{1} '-' f1],'Interpreter','none')
    ylabel([EPOCHS{2} '-' f2],'Interpreter','none')


    c=c+1;
    disp([req_params.cell_type{i} ': ' num2str(signrank([effects1(indType).(f1)]))])
    
end


%%
clc

h1 = [pVals1.(f1)]<0.05;
h2 = [pVals2.(f2)]<0.05;
h_1and2 = h1&h2;

for i = 1:N

    indType = find(strcmp(req_params.cell_type{i}, cellType));

    disp([req_params.cell_type{i} ':'])

    disp([EPOCHS{1} '-' f1 ':' num2str(sum(h1(indType))) '/' ...
        num2str(length(h1(indType))) '=' num2str(mean(h1(indType)))])

    disp([EPOCHS{2} '-' f2 ':' num2str(sum(h2(indType))) '/' ...
        num2str(length(h2(indType))) '=' num2str(mean(h2(indType)))])
    
   
    disp(['Both' ':' num2str(sum(h_1and2(indType))) '/' ...
        num2str(length(h_1and2(indType))) '=' num2str(mean(h_1and2(indType)))])

    

end


