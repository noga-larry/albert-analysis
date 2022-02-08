
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 0;
raster_params.time_after = 800;
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

    omegas = calOmegaSquare(response,{match_p});
    omegaT(ii) = omegas(1).value;
    omegaR(ii) = omegas(2).value + omegas(3).value;
    
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
