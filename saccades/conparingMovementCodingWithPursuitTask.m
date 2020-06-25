clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

tasks = {'saccade_8_dir_75and25','pursuit_8_dir_75and25'}
req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

%find cells that were recorded in both tasks
req_params.task = 'saccade_8_dir_75and25';
lines1 = findLinesInDB (task_info, req_params);
req_params.task = 'pursuit_8_dir_75and25';
lines2 = findLinesInDB (task_info, req_params);
IDs = intersect([task_info(lines1).cell_ID],[task_info(lines2).cell_ID]);

raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;


omegaT = nan(2,length(IDs));
omegaR = nan(2,length(IDs));
omegaD = nan(2,length(IDs));

for ii = 1:length(IDs)
    req_params.ID = IDs(ii);
    
    for j=1:length(tasks)
    req_params.task = tasks{j};
    lines = findLinesInDB (task_info, req_params);
    cells = findPathsToCells (supPath,task_info,lines);
    
    data = importdata(cells{1});
    cellType{ii} = data.info.cell_type;

   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_d = match_d(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{9,2};
    msw = tbl{8,5};
      % N = length(response(:));
    
    %omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(j,ii) = omega(tbl,2);
    omegaR(j,ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(j,ii) = omega(tbl,4)+omega(tbl,6);
    end
    
end


%%

boolPC = strcmp('PC ss', cellType);

figure;
subplot(3,1,1)
scatter(omegaT(1,boolPC),omegaT(2,boolPC),'filled','k'); hold on
scatter(omegaT(1,~boolPC),omegaT(2,~boolPC),'filled','m');
p1 = signrank(omegaT(1,boolPC),omegaT(2,boolPC));
p2 = signrank(omegaT(1,~boolPC),omegaT(2,~boolPC));
xlabel('time saccade')
ylabel('time pursuit')
refline(1,0)
title(['PC ss: p_{time} = ' num2str(p1) ', CRB: p_{time} = ' num2str(p2)])

subplot(3,1,2)
scatter(omegaR(1,boolPC),omegaR(2,boolPC),'filled','k'); hold on
scatter(omegaR(1,~boolPC),omegaR(2,~boolPC),'filled','m');
p1 = signrank(omegaR(1,boolPC),omegaR(2,boolPC));
p2 = signrank(omegaR(1,~boolPC),omegaR(2,~boolPC));
xlabel('reward saccade')
ylabel('reward pursuit')
refline(1,0)
title(['PC ss: p_{reward} = ' num2str(p1) ', CRB: p_{reward} = ' num2str(p2)])

subplot(3,1,3)
scatter(omegaD(1,boolPC),omegaD(2,boolPC),'filled','k'); hold on
scatter(omegaD(1,~boolPC),omegaD(2,~boolPC),'filled','m');
p1 = signrank(omegaD(1,boolPC),omegaD(2,boolPC));
p2 = signrank(omegaD(1,~boolPC),omegaD(2,~boolPC));
xlabel('direction saccade')
ylabel('direction pursuit')
refline(1,0)
title(['PC ss: p_{direction} = ' num2str(p1) ', CRB: p_{direction} = ' num2str(p2)])

