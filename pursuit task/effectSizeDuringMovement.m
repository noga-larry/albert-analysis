clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH =  'targetMovementOnset'; 


req_params = reqParamsEffectSize("both");
req_params.cell_type = {'CRB'};


% 
% %pursuit
% ID_cs_sig = [4322	4328	4455	4457	4582	4610	4810	4825	4851	4942	5156	5358	5381	5434	5458	5620	5696];
% %saccades
% ID_cs_sig = [4238	4239	4243	4328	4457	4535	4610	4810	5214	5358	5381	5434	5458	5620	5725];
% 
% req_params.cell_type = {'SNR'}; lines_snr = findLinesInDB (task_info, req_params);
% req_params.cell_type = {'PC ss','SNR'};req_params.ID = ID_cs_sig;  lines_ss = findLinesInDB (task_info, req_params);
%lines = union(lines_snr,lines_ss);

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    PC_score(ii) = task_info(lines(ii)).crb_pc_score;
    
    [effects(ii), tbl, rate(ii)] = effectSizeInEpoch(data,EPOCH); 
    time_significance(ii) = tbl{2,end}<0.05; %time
    
    task_info(lines(ii)).time_sig_motion = time_significance(ii);
    
end
save ([task_DB_path],'task_info')


%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    if isempty(indType)
        continue
    end
    disp('Frac cell with insignificant time effect:')    
    disp ([req_params.cell_type{i} ': ' num2str(mean(time_significance(indType)))...
        ', n = ' num2str(sum(time_significance(indType)))]) 
    
    subplot(3,N,i)
    scatter([effects(indType).time],[effects(indType).reward],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).reward]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).direction],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).direction]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward],[effects(indType).direction],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).direction],[effects(indType).reward]);
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
    
end

%%
figure;


bins = linspace(-0.2,1,100);
f = fields(effects);

for j = 1:length(f)
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        subplot(length(f),1,j)
        plotHistForFC([effects(indType).(f{j})],bins); hold on
    end
    
    title(f{j})
    legend(req_params.cell_type)

end

legend(req_params.cell_type)
sgtitle('Motion','Interpreter', 'none');

%% tests

x = [effects.direction];

p = bootstraspWelchANOVA(x', cellType');

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('BG msn', cellType))))


x = [effects.direction];

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = bootstrapTTest(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
    
end

%
x = [effects.direction];

p = bootstraspWelchANOVA(x(time_significance)', cellType(time_significance)')

p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('BG msn', cellType))))


% floc
load('floc data motion.mat')

x = [effects.reward];
x_floc = [floc_eff.direction];
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('CRB', floc_type))))

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('PC ss', floc_type))))

%% 
figure
scatter(PC_score,[effects.direction])
xlabel('PC score');  ylabel('Effect size')
[r,p] = corr(PC_score',[effects.direction]',...
    'type','spearman','rows','pairwise');
title(['Spearman: r = ' num2str(r) ', p = ' num2str(p) ',n = ' num2str(length(PC_score))])

