
clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;
EPOCH = 'cue'; 

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
%req_params.task = 'saccade_8_dir_75and25';
%req_params.task = 'rwd_direction_tuning';

req_params.num_trials = 100;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;    
    
    [effects(ii), time_significance(ii)] = effectSizeInEpoch(data,EPOCH);    
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

save ([task_DB_path '.mat'],'task_info')


%%
figure;
N = length(req_params.cell_type);
for i = 1:length(req_params.cell_type)
    
    subplot(2,ceil(N/2),i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    disp('Frac cell with insignificant time effect:')
    disp ([req_params.cell_type{i} ': ' num2str(mean(time_significance(indType)))...
        ', n = ' num2str(sum(time_significance(indType)))])
    
    scatter([effects(indType).time],[effects(indType).reward],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).reward]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])

end

%% comparisoms fron input-output figure

x = [effects.reward];
inputOutputFig(x,cellType)

% ranksum for SNpr
p = ranksum(x(find(strcmp('SNR', cellType))),...
    x(find(~strcmp('SNR', cellType))))

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = signrank(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
    
    
end
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




