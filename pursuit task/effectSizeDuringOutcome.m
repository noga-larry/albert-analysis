clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'reward';


req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
%req_params.cell_type = {'PC cs'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    
    [effects(ii), tbl] = effectSizeInEpoch(data,EPOCH);    
    task_info(lines(ii)).time_sig_outcome = tbl{2,end}<0.05; %time

    
    if mod(ii,50)==0
        disp(ii)
    end
    
end

save ([task_DB_path '.mat'],'task_info')

%%
f = figure; f.Position = [10 80 700 500];
ax1 = subplot(1,5,1); title('Direction')
ax2 = subplot(1,5,2);title('Time')
ax3 = subplot(1,5,3); title('Reward prob')
ax4 = subplot(1,5,4); title('Outcome')
ax5 = subplot(1,5,5); title('Interactions')

bins = linspace(-0.2,1,100);

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    disp('Frac cell with insignificant time effect:')
    disp ([req_params.cell_type{i} ': ' num2str(mean(time_significance(indType)))...
        ', n = ' num2str(sum(time_significance(indType)))])
end
    

title(ax1,'Direction')
title(ax2,'Time')
title(ax3,'Reward Prob')
title(ax4,'Outcome')
title(ax4,'suprise')
legend(req_params.cell_type)

%% comparisoms fron input-output figure
figure

x = [effects.outcome];

p = bootstraspWelchANOVA(x', cellType')

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('BG msn', cellType))))



x = [effects.prediction];
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = bootstrapTTest(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
        
end

x = [effects.outcome];

p = bootstraspWelchANOVA(x', cellType')

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType) | strcmp('CRB', cellType))))

p = bootstraspWelchTTest(x(find(strcmp('BG msn', cellType))),...
    x(find(strcmp('PC ss', cellType) | strcmp('CRB', cellType))))

p = bootstraspWelchTTest(x(find(strcmp('CRB', cellType))),...
    x(find(strcmp('PC ss', cellType))))

%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    
    subplot(2,ceil(N/2),i)
    scatter([effects(indType).outcome],[effects(indType).prediction],'filled','k'); hold on
    p = bootstrapTTest ([effects(indType).outcome],...
        [effects(indType).prediction]);

    xlabel('outcome+time*outcome')
    ylabel('prediction')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ', n = ' num2str(length(indType))])
    
end


%%

inx = find([task_info(lines).time_sig_outcome])
x = [effects.outcome];
x = x(inx)

relCellType = cellType(inx);

p = bootstraspWelchANOVA(x', relCellType')

p = bootstraspWelchTTest(x(find(strcmp('SNR', relCellType))),...
    x(find(strcmp('PC ss', relCellType) | strcmp('CRB', relCellType))))

p = bootstraspWelchTTest(x(find(strcmp('BG msn', relCellType))),...
    x(find(strcmp('PC ss', relCellType) | strcmp('CRB', relCellType))))

p = bootstraspWelchTTest(x(find(strcmp('CRB', relCellType))),...
    x(find(strcmp('PC ss', relCellType))))