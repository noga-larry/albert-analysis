clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'speed_2_dir_0,50,100';
req_params.num_trials = 90;
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
omegaV = nan(1,length(cells));


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    match_d = match_d(find(~boolFail))';
    [~,match_v] = getVelocities (data);
    match_v = match_v(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);
    groupV = repmat(match_v',size(response,1),1);
    
    [p,tbl] = anovan(response(:),{groupT(:),groupR(:),groupD(:),groupV(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{end,2};
    SSe = tbl{end-1,2};
    msw = tbl{end-1,5};
    N = length(response(:));
    
    %omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,6);
    omegaD(ii) = omega(tbl,4)+omega(tbl,7);
    omegaV(ii) = omega(tbl,5)+omega(tbl,8);
    
    overAllExplained(ii) = (totVar - SSe)/totVar;
    
end

%%
f = figure; f.Position = [10 80 700 500];
n = 4;
ax1 = subplot(1,n,1); title('Direction')
ax2 = subplot(1,n,2);title('Time')
ax3 = subplot(1,n,3); title('Reward')
ax4 = subplot(1,n,4); title('Velocity')

bins = linspace(-0.2,0.4,100);

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
    plotHistForFC(omegaV(indType),bins); hold on
    xlabel('Effect size')
end

sgtitle('Motion','Interpreter', 'none');