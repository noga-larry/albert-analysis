clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'reward';

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};

req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;
req_params.ID = 4000:6000;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    effects(ii) = effectSizeInEpoch(data,EPOCH);    

    
    if mod(ii,50)==0
        disp(ii)
    end
    
end

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
    
    axes(ax1)
    plotHistForFC(omegaD(indType),bins); hold on
    xlabel('Effect size')
    
    axes(ax2)
    plotHistForFC(omegaT(indType),bins); hold on
    xlabel('Effect size')
    
    axes(ax3)
    plotHistForFC(omegaR(indType),bins); hold on
    xlabel('Effect size')
    
    axes(ax4)
    plotHistForFC(omegaO(indType),bins); hold on
    xlabel('Effect size')
    
   axes(ax5)
    plotHistForFC(omegaSup(indType),bins); hold on
    xlabel('Effect size')
    
end

title(ax1,'Direction')
title(ax2,'Time')
title(ax3,'Reward Prob')
title(ax4,'Outcome')
title(ax4,'suprise')
legend(req_params.cell_type)

%% comparisoms fron input-output figure
figure

effect_size = [effects.outcome];

inputOutputFig([effects.reward],cellType)



%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    
    subplot(2,ceil(N/2),i)
    scatter([effects(indType).outcome],[effects(indType).prediction],'filled','k'); hold on
    p = signrank([effects(indType).outcome],[effects(indType).prediction]);
    xlabel('outcome+time*outcome')
    ylabel('prediction')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
end