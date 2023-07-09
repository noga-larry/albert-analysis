
clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;
EPOCH = 'cue'; 

req_params = reqParamsEffectSize("both");
req_params.cell_type = {'PC cs'};

%req_params.ID = 4778;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    assert(length(data.trials)>req_params.num_trials)

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;    
    
    [effects(ii), tbl, rate(ii), num_trials(ii)] = effectSizeInEpoch(data,EPOCH); 
    time_significance(ii) = tbl{2,end}<0.05; %time
    task_info(lines(ii)).time_sig_cue = time_significance(ii);
    
    if PLOT_CELL
        prob = unique(match_p);
        for p = 1:length(prob)
            subplot(2,ceil(length(prob)/2),p)
            plotRaster(raster(:, match_p==prob(p)),raster_params)
            subtitle(num2str(prob(p)))
        end
        title([cellType{ii} 'ID: ' num2str(cellID(ii)) 'omega R: ' num2str(omegaR(ii)) ', omega T:' num2str(omegaT(ii))])
    end
end

%save ([task_DB_path],'task_info')


%%
clc
figure;
N = length(req_params.cell_type);
for i = 1:length(req_params.cell_type)
    
    subplot(2,ceil(N/2),i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    disp('Frac cell with insignificant time effect:')
    disp ([req_params.cell_type{i} ': ' num2str(mean(time_significance(indType)))...
        ', n = ' num2str(sum(time_significance(indType))) ,'/' num2str(length(indType))])
    
    scatter([effects(indType).time],[effects(indType).reward_probability],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).reward_probability]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])

end

%% tests

x = [effects.reward_probability];

inputOutputFig(x,cellType)

p = bootstraspWelchANOVA(x', cellType');

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('BG msn', cellType))))


x = [effects.reward_probability];

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = bootstrapTTest(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
        
end


% time-significant

x = [effects.reward];

p = bootstraspWelchANOVA(x(time_significance)', cellType(time_significance)')

p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('BG msn', cellType))))


%% floc
load('floc data cue.mat')

x = [effects.reward_probability];
x_floc = [floc_eff.reward_probability];
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('CRB', floc_types))))

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('PC ss', floc_types))))
%%
figure;


bins = linspace(-0.2,1,50);
flds = fields(effects);

for j = 1:length(flds)
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        subplot(length(flds),1,j)
        plotHistForFC([effects(indType).(flds{j})],bins); hold on
    end
    title(flds{j})
end

legend(req_params.cell_type)
sgtitle('Cue','Interpreter', 'none');


%% correlation with rate

figure;
flds = fields(effects);
N = length(req_params.cell_type);

for j =1:length(flds)
    for i = 1:N

        subplot(length(flds),N,(j-1)*N+i)
        indType = find(strcmp(req_params.cell_type{i}, cellType));

        scatter(rate(indType),[effects(indType).(flds{j})],'filled','k'); hold on
        [r,p] = corr([effects(indType).(flds{j})]',rate(indType)','type','Spearman','rows','pairwise');
        ylabel(flds{j})
        xlabel('rate')
        title([flds{j} ' ' req_params.cell_type{i}, ': r= ' num2str(r) ', p = ' num2str(p)], 'Interpreter','none')
    end
end


inputOutputFig(rate,cellType)