
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);

    [p,tbl,~,~] = anovan(response(:),{groupT(:),groupR(:)},'model','interaction','display','off');
    %ss = sumsOfSquares(response(:),{groupT(:),groupR(:)});
    
%     ss_error(ii,1) = tbl{5,2};ss_error(ii,2) = ss.error;
%     ss_a(ii,1) = tbl{2,2};ss_a(ii,2) = ss.X1;
%     ss_b(ii,1) = tbl{3,2};ss_b(ii,2) = ss.X2;
%     ss_ab(ii,1) = tbl{4,2};ss_ab(ii,2) = ss.interaction;
    totVar = tbl{6,2};
    msw = tbl{5,5};
    SSe = tbl{5,2};
    N = length(response(:));
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,4);
      
    %omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    
    overAllExplained(ii) = (totVar - SSe)/totVar;

    
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


bins = linspace(-0.2,1.4,100);

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

%% 
figure;


subplot(2,2,1)
scatter(ss_error(:,1),ss_error(:,2))
refline(1,0)
title('Error')
xlabel('MATLAB'); ylabel('Mine')

subplot(2,2,2)
scatter(ss_a(:,1),ss_a(:,2))
refline(1,0)
title('Time')
xlabel('MATLAB'); ylabel('Mine')

subplot(2,2,3)
scatter(ss_b(:,1),ss_b(:,2))
refline(1,0)
title('Reward')
xlabel('MATLAB'); ylabel('Mine')

subplot(2,2,4)
scatter(ss_ab(:,1),ss_ab(:,2))
refline(1,0)
title('Interaction')
xlabel('MATLAB'); ylabel('Mine')
