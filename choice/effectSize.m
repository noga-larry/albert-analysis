clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

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

bool = cellID>5000


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
    subtitle(['p = ' num2str(p)])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).direction]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).reward],[effects(indType).direction]);
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
end