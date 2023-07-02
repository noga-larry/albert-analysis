clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH =  'targetMovementOnset'; 


req_params = reqParamsEffectSize("both");

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


for ii = 1:length(cells)
    
    data = importdata(cells{ii});

   % data = getBehavior (data,supPath);


    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [effects(ii), tbl, rate(ii)] = effectSizeInEpoch(data,EPOCH,...
        'velocityInsteadReward',false);
    time_significance(ii) = tbl{2,end}<0.05; %time
    
    sse(ii) = tbl{end-1,2};
    ssb(ii) = tbl{3,2};
    
    task_info(lines(ii)).time_sig_motion = time_significance(ii);
    
end
%save ([task_DB_path],'task_info')


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
    scatter([effects(indType).time],[effects(indType).reward_probability],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).reward_probability]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).directions],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).directions]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward_probability],[effects(indType).directions],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).directions],[effects(indType).reward_probability]);
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

x = [effects.directions];

p = bootstraspWelchANOVA(x', cellType');

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('BG msn', cellType))))


x = [effects.velocity];

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

figure;
subplot(2,1,1)
gscatter(log(sse),log(ssb),cellType')
corr(log(sse)',log(ssb)','type','spearman')
xlabel('log sse'); ylabel('log ssb')

subplot(2,1,2)
gscatter(log(sse),log(rate),cellType')
[r,p] = corr(log(sse)',log(rate)','type','spearman')
xlabel('log sse'); ylabel('log rate')

figure;
log_rate = log(rate);

% Scatter plot with color-coded dots
scatter(ssb, sse, [], rate, 'filled');
colorbar;

% Set labels and title
xlabel('SSB');
ylabel('SSE');
title('SSE vs SSB with Log Rate');

% Adjust figure properties
c = colorbar;
c.Label.String = 'Log Rate';


[rho,pval]  = partialcorr(log(sse)',log(ssb)',log(rate)','type','spearman','Rows','pairwise')