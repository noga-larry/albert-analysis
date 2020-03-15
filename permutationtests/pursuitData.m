clear all
supPath = 'C:\noga\TD complex spike analysis\Data\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;
varNames =  {'reward'}; 

statistic_func = @intergroupVar;


ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    statDist{ii} = permVarFrac(response',match_p,statistic_func,...
    'plotCell',false,'varNames',varNames);
    
    real_stat = statistic_func(response',match_p);

    totVtime(ii) = mean(statDist{1})-mean(statDist{2});
    timeVind(ii) = mean(statDist{2}) - real_stat;
    
    h(ii) = mean(statDist{1}) - mean(real_stat);
    percentile(ii) = mean(statDist{1} < real_stat);
   
    
 end

figure;
scatter(totVtime,timeVind); hold on
inx = find(percentile<0.01);
scatter(totVtime(inx),timeVind(inx));
refline(1,0)




%%
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');


req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;
varNames =  {'reward','direction'}; 

statistic_func = @intergroupVar;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    [~,match_d] = getDirections (data);
    match_p = match_p(find(~boolFail))';
    match_d = match_d(find(~boolFail))';
    
    match = [match_p, match_d];
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    statDist{ii} = permVarFrac(response',match,statistic_func,...
        'plotCell',false,'varNames',varNames);
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match(:,1)',size(response,1),1);
    groupD = repmat(match(:,2)',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{9,2};
    msw = tbl{8,5};
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,5)+omega(tbl,3);
    omegaD(ii) = omega(tbl,6)+omega(tbl,4);
    
    
    
    
%     real_stat = statistic_func(response',match);
%  
%   
%     h(ii) = mean(statDist{1}) - mean(real_stat);
%     percentile(ii) = mean(statDist{1} < real_stat);
%     
%     normalization(ii) = (mean(statDist{1}) - mean(real_stat))/mean(statDist{1});
end

%%

h = @(x,dim) (mean(x{2})-mean(x{dim}))%*(mean(x{1})-x{end}...
      %  /mean(x{1})^2);
f = @(x) (mean(x{1} > x{4}))>(1-0.05);
hReward = @(x) h(x,3);
hDirection = @(x) h(x,4);
hTime = @(x,dim) (mean(x{1})-mean(x{2}));
rewardCost = cellfun(hReward,statDist);
dirCost = cellfun(hDirection,statDist);
timeCost = cellfun(hTime,statDist);
inx = find(cellfun(f,statDist));
figure;
scatter(rewardCost,dirCost); hold on
scatter(rewardCost(inx),dirCost(inx)); hold on
xlabel('Total-reward')
ylabel('Total-direction')
p = signrank(rewardCost,dirCost);
title(['p = ' num2str(p)])
axis equal
refline(1,0)

figure;
m = [timeCost;rewardCost;dirCost];
plot([1,2,3],m,'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'total-time', 'time-reward' ,'time-direction'})

figure;
plot([1,2,3],[ettaT;ettaR;ettaD],'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'time', 'time*reward' ,'time*direction'})


figure;
plot([1,2,3],[omegaT;omegaR;omegaD],'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'time', 'time*reward' ,'time*direction'})

figure;
subplot(1,3,1)
scatter(timeCost,ettaT)
title('time')
xlabel('bootstrap'); ylabel('etta')
subplot(1,3,2)
scatter(rewardCost,ettaR)
title('reward')
xlabel('bootstrap'); ylabel('etta')
subplot(1,3,3)
scatter(dirCost,ettaD)
title('direction')
xlabel('bootstrap'); ylabel('etta')




