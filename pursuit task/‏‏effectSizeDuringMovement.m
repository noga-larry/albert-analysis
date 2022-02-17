clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
bin_sz = 50;
 
ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));
omegaD = nan(1,length(cells));

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);

    omegas = calOmegaSquare(response,{match_d,match_p},'partial',true);
    
    omegaT(ii) = omegas(1).value;
    omegaD(ii) = omegas(2).value + omegas(4).value;
    omegaR(ii) = omegas(3).value + omegas(5).value;
    
    overAllExplained(ii) = omegas(6).value;
    
    if omegaD(ii)>0.6
        list = [list, data.info.cell_ID];
    end
    
end

%%

figure;
subplot(3,1,1)
scatter(omegaT,omegaR,'filled'); 
p = signrank(omegaT,omegaR);
xlabel('time')
ylabel('reward+time*reward')
refline(1,0)
title(['p_{reward} = ' num2str(p)])

subplot(3,1,2)
scatter(omegaT,omegaD,'filled'); 
p = signrank(omegaT,omegaD);
title(['p_{movement} = ' num2str(p)])
xlabel('$\eta^2$ time','interpreter','latex')
ylabel('direction+time*direcion')
 refline(1,0)

subplot(3,1,3)
scatter(omegaR,omegaD,'filled'); 
p = signrank(omegaR,omegaD)
title(['p = ' num2str(p)])
xlabel('reward+time*reward')
ylabel('direction+time*direcion')
refline(1,0)

figure;

bins = -0.1:0.02:1;
plotHistForFC(omegaT,bins,'g'); hold on
plotHistForFC(omegaR,bins,'r'); hold on
plotHistForFC(omegaD,bins,'b'); hold on
legend('T','R','D')

%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,N,i)
    scatter(omegaT(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaR(indType));
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
        
    subplot(3,N,i+N)
    scatter(omegaT(indType),omegaD(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaD(indType));
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
    subplot(3,N,i+2*N)
    scatter(omegaD(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaD(indType),omegaR(indType));
    ylabel('reward+time*reward')
    xlabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
end

%%
f = figure; f.Position = [10 80 700 500];
ax1 = subplot(1,3,1); title('Direction')
ax2 = subplot(1,3,2);title('Time')
ax3 = subplot(1,3,3); title('Reward')

bins = linspace(-0.2,1,50);

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
end
kruskalwallis(omegaT,cellType)
title(ax1,'Direction')
title(ax2,'Time')
title(ax3,'Reward')
legend(ax1,req_params.cell_type)
legend(ax2,req_params.cell_type)
legend(ax3,req_params.cell_type)


sgtitle('Motion','Interpreter', 'none');
%%

f = figure; f.Position = [10 80 700 500];
bins = -0.3:0.05:1;

overallExplained = omegaR+omegaD+omegaT;
p = ranksum(overallExplained(indType),overallExplained(~indType))
plotHistForFC(overallExplained(indType),bins,'g'); hold on
plotHistForFC(overallExplained(~indType),bins,'r'); hold on
legend('SS', 'CRB')
title(['Over all: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(indType)) ', n_{crb} = ' num2str(sum(~indType))])


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
%% CV and
raster_params.align_to = 'cue';
raster_params.time_before = 200;
raster_params.time_after = 600;
raster_params.smoothing_margins = 0;
req_params.num_trials = 50;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    raster = getRaster(data,find(~boolFail),raster_params);
    FR(ii) = mean(mean(raster)*1000);
    CV2(ii) = nanmean(getCV2(data,find(~boolFail),raster_params));
    CV(ii) = nanmean(getCV(data,find(~boolFail),raster_params));
end

figure; 
scatter(FR(indType),overallExplained(indType),'k'); hold on
scatter(FR(~indType),overallExplained(~indType),'m'); hold on
legend('SS', 'CRB')

xlabel('FR')
ylabel('Sum of effects')
[r1,p1] = corr(FR(indType)',overallExplained(indType)','type','Spearman')
[r2,p2] = corr(FR(~indType)',overallExplained(~indType)','type','Spearman')
title(['SS : r = ' num2str(r1) ', ' num2str(p1) ', CRB : r = ' num2str(r2) ', ' num2str(p2)])
