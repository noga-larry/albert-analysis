clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 300;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
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
    cellType{ii} = data.info.cell_type;
   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_d = match_d(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','full','display','off','sstype',1);
    
    totVar = tbl{10,2};
    SSe = tbl{9,2};
    msw = tbl{9,5};
    N = length(response(:));
    
    %omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(ii) = omega(tbl,4)+omega(tbl,6);
    omegaRD(ii) = omega(tbl,7)+omega(tbl,8);
    
    overAllExplained(ii) = (totVar - SSe)/totVar;
    
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

for i = 1:length(req_params.cell_type)
    
    figure;
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,1,1)
    scatter(omegaT(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaR(indType));
    xlabel('time')
    ylabel('reward+time*reward')
    refline(1,0)
    title(['p = ' num2str(p)])
        
    subplot(3,1,2)
    scatter(omegaT(indType),omegaD(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaD(indType));
    xlabel('time')
    ylabel('direction+time*direcion')
    refline(1,0)
    title(['p= ' num2str(p)])
    
    subplot(3,1,3)
    scatter(omegaD(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaD(indType),omegaR(indType));
    ylabel('reward+time*reward')
    xlabel('direction+time*direcion')
    refline(1,0)
    title(['p = ' num2str(p)])
    
    sgtitle(['Motion:' req_params.cell_type{i}])
end

%%
f = figure; f.Position = [10 80 700 500];
ax1 = subplot(3,1,1); title('Direction')
ax2 = subplot(3,1,2);title('Time')
ax3 = subplot(3,1,3); title('Reward')

bins = linspace(-0.2,1.4,100);

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    axes(ax1)
    plotHistForFC(omegaD(indType),bins); hold on
    
    axes(ax2)
    plotHistForFC(omegaT(indType),bins); hold on
    
    axes(ax3)
    plotHistForFC(omegaR(indType),bins); hold on
    
end

title(ax1,'Direction')
title(ax2,'Time')
title(ax3,'Reward')
legend(req_params.cell_type)
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
