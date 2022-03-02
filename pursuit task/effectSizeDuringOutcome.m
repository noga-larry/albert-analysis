clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'reward';
raster_params.time_before = 0;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));
omegaD = nan(1,length(cells));
omegaO = nan(1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
    
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
    
    omegas = calOmegaSquare(response,{match_p,match_d,match_o},'partial',true,'model','interaction');
    
    omegaT(ii) = omegas(1).value;
    omegaR(ii) = omegas(2).value + omegas(5).value;
    omegaD(ii) = omegas(3).value + omegas(6).value;
    omegaO(ii) = omegas(4).value + omegas(7).value;
    %omegaSup(ii) = omegas(9).value + omegas(12).value;
    
    overAllExplained(ii) = omegas(10).value;
    
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
