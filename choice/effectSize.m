clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.cell_type = {'SNR'};
req_params.task = 'choice';
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
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
   
    boolFail = [data.trials.fail] | ~[data.trials.choice]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_d = match_d(1,:);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);

    omegas = calOmegaSquare(response,{match_d,match_p}); 
    
    omegaT(ii) = omegas(1).value;
    omegaD(ii) = omegas(2).value + omegas(4).value;
    omegaR(ii) = omegas(3).value + omegas(5).value;
    
    overAllExplained(ii) = omegas(6).value;
    
    if omegaD(ii)>0.6
        list = [list, data.info.cell_ID];
    end
    
end

%%
f = figure; f.Position = [10 80 700 500];
ax1 = subplot(1,3,1); title('Direction')
ax2 = subplot(1,3,2);title('Time')
ax3 = subplot(1,3,3); title('Reward')

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
end

title(ax1,'Direction')
title(ax2,'Time')
title(ax3,'Reward')
legend(req_params.cell_type)
sgtitle(raster_params.align_to,'Interpreter', 'none');

kruskalwallis(omegaT,cellType)

%%

bool = cellID<5000


N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType) & bool);
    
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