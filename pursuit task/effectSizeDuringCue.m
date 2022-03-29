
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PLOT_CELL = false;

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
%req_params.ID = 5455;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;    

    omegas = effectSizeInEpoch(data,'cue');
    omegaT(ii) = omegas(1).value;
    omegaR(ii) = omegas(2).value + omegas(3).value;

    if PLOT_CELL
        prob = unique(match_p);
        for p = 1:length(prob)
            subplot(2,ceil(length(prob)/2),p)
            plotRaster(raster(:, match_p==prob(p)),raster_params)
            subtitle(num2str(prob(p)))
        end
        title([cellType{ii} 'ID: ' num2str(cellID(ii)) 'omega R: ' num2str(omegaR(ii)) ', omega T:' num2str(omegaT(ii))])
        if omegaR(ii)>0.01
            pause
        end
    end
end

%%
figure;
N = length(req_params.cell_type);
for i = 1:length(req_params.cell_type)
    
    subplot(2,ceil(N/2),i)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    scatter(omegaT(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaR(indType));
    xlabel('time')
    ylabel('reward+time*reward')
    subtitle(['p = ' num2str(p)])
    equalAxis() 
    refline(1,0)
 
    title(req_params.cell_type{i})
end


%%
f = figure; f.Position = [10 80 700 500];
ax1 = subplot(1,2,1); title('Reward')
ax2 = subplot(1,2,2);title('Time')


bins = linspace(-0.2,1,50);

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    plotHistForFC(omegaR(indType),bins); hold on
    
    axes(ax2)
    plotHistForFC(omegaT(indType),bins); hold on
    
end

title(ax1,'Reward')
title(ax2,'Time')
legend(req_params.cell_type)
sgtitle('Cue','Interpreter', 'none');

%% comparisoms fron input-output figure
figure

effect_size = omegaT

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
Data = [omegaR',input_output',bg_crb']
out = SRH_test(Data,'area','input_output')

%%

