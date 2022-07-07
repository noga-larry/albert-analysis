clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.num_trials = 120;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;


EPOCH = 'reward';

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;   
   
    effects(ii) = effectSizeInEpoch(data,EPOCH);
    
   
end

%%

figure;

bins = linspace(-0.2,1,50);
f = fields(effects);

for j = 1:length(f)
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        subplot(length(f),1,j)
        plotHistForFC([effects(indType).(f{j})],bins); hold on
    end
    title(f{j})
end

legend(req_params.cell_type)
sgtitle('Cue','Interpreter', 'none');

%%


x = [effects.reward];
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = signrank(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
    
    
end

x = [effects.outcome];
% ranksum for SNpr
p = ranksum(x(find(strcmp('SNR', cellType))),...
    x(find(~strcmp('SNR', cellType))))

%%
bool = cellID<inf


N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType) & bool);
    
    subplot(3,N,i)
    scatter([effects(indType).time],[effects(indType).reward],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).reward]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) 'n = ' num2str(length(indType))])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).direction]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) 'n = ' num2str(length(indType))]) 
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).reward],[effects(indType).direction]);
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) 'n = ' num2str(length(indType))])
    
end


%%

figure

effect_size = [effects.outcome];


inputOutputFig(effect_size,cellType)


x1 = subplot(2,2,1); hold on
x2 = subplot(2,2,2); hold on
x3 = subplot(2,2,3); hold on
x4 = subplot(2,2,4); hold on

indType = find(strcmp('SNR', cellType));
plot(x1,3,effect_size(indType),'ob')
ci = bootci(2000,@median,effect_size(indType))
errorbar(x2,3,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

indType = find(strcmp('BG msn', cellType));
plot(x1,4,effect_size(indType),'or')
ci = bootci(2000,@median,effect_size(indType))-median(effect_size(indType))
errorbar(x2,4,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

p = ranksum(effect_size(find(strcmp('SNR', cellType))),effect_size(find(strcmp('BG msn', cellType))))
title(x2,['p = ' num2str(p) ', n_{SNR} = ' num2str(sum(strcmp('SNR', cellType))) ...
    ', n_{msn} = ,' num2str(sum(strcmp('BG msn', cellType)))])


indType = find(strcmp('PC ss', cellType));
plot(x3,3,effect_size(indType),'ob')
ci = bootci(2000,@median,effect_size(indType)) - median(effect_size(indType))
errorbar(x4,3,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)


indType = find(strcmp('CRB', cellType));
plot(x3,4,effect_size(indType),'or')
ci = bootci(2000,@median,effect_size(indType))
errorbar(x4,4,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

p = ranksum(effect_size(find(strcmp('PC ss', cellType))),effect_size(find(strcmp('CRB', cellType))))
title(['p = ' num2str(p) ', n_{ss} = ' num2str(sum(strcmp('PC ss', cellType))) ...
    ', n_{crb} = ,' num2str(sum(strcmp('CRB', cellType)))])

input_output = cellfun(@(x)~isempty(x),regexp('PC ss|SNR',cellType)) 
bg_crb = cellfun(@(x)~isempty(x),regexp('PC ss|CRB',cellType)) 
Data = [effect_size',input_output',bg_crb']
out = SRH_test(Data,'area','input_output')
