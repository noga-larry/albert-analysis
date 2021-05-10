
clear; clc
[task_info, supPath] = loadDBAndSpecifyDataPaths('Golda');

req_params.grade = 7;
req_params.cell_type = 'PC|CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

type = nan(1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
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
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(ii) = omega(tbl,4)+omega(tbl,6);
    
    if strcmp(data.info.cell_type,'CRB')
        type(ii)=1;
    elseif strcmp(data.info.cell_type,'PC ss')
        type(ii)=0;
    elseif strcmp(data.info.cell_type,'PC cs')
        type(ii)=2;
    end
    
    
end

%%
figure;
crbs = find(type==1);
sspks = find(type==0);
cspks = find(type==2);

subplot(3,3,1)
hist(omegaT(crbs),20); 
p = signrank(omegaT(crbs));
title(['CRB, time, p = ' num2str(p)])
subplot(3,3,2)
hist(omegaT(sspks),20); 
p = signrank(omegaT(sspks));
title(['Sspks, time, p = ' num2str(p)])
subplot(3,3,3)
hist(omegaT(cspks),20); 
p = signrank(omegaT(cspks));
title(['Cspks, time, p = ' num2str(p)])


subplot(3,3,4)
hist(omegaR(crbs),20); 
p = signrank(omegaR(crbs));
title(['CRB, reward, p = ' num2str(p)])
subplot(3,3,5)
hist(omegaR(sspks),20); 
p = signrank(omegaR(sspks));
title(['Sspks, reward, p = ' num2str(p)])
subplot(3,3,6)
hist(omegaR(cspks),20); 
p = signrank(omegaR(cspks));
title(['Cspks, reward, p = ' num2str(p)])

subplot(3,3,7)
hist(omegaD(crbs),20); 
p = signrank(omegaD(crbs));
title(['CRB, movement, p = ' num2str(p)])
subplot(3,3,8)
hist(omegaD(sspks),20); 
p = signrank(omegaD(sspks));
title(['Sspks, movement, p = ' num2str(p)])
subplot(3,3,9)
hist(omegaD(cspks),20); 
p = signrank(omegaD(cspks));
title(['Cspks, movement, p = ' num2str(p)])


%%
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC|CRB';
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

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

type = nan(1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    
    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{6,2};
    msw = tbl{5,5};
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,4);
    
    if strcmp(data.info.cell_type,'CRB')
        type(ii)=1;
    elseif strcmp(data.info.cell_type,'PC ss')
        type(ii)=0;
    elseif strcmp(data.info.cell_type,'PC cs')
        type(ii)=2;
    end
    
    
end

%%
figure;
crbs = find(type==1);
sspks = find(type==0);
cspks = find(type==2);

subplot(2,3,1)
hist(omegaR(crbs),20); 
p = signrank(omegaR(crbs));
title(['CRB, reward, p = ' num2str(p)])
subplot(2,3,2)
hist(omegaR(sspks),20); 
p = signrank(omegaR(sspks));
title(['Sspks, reward, p = ' num2str(p)])
subplot(2,3,3)
hist(omegaR(cspks),20); 
p = signrank(omegaR(cspks));
title(['Cspks, reward, p = ' num2str(p)])

subplot(2,3,4)
hist(omegaT(crbs),20); 
p = signrank(omegaT(crbs));
title(['CRB, time, p = ' num2str(p)])
subplot(2,3,5)
hist(omegaT(sspks),20); 
p = signrank(omegaT(sspks));
title(['Sspks, time, p = ' num2str(p)])
subplot(2,3,6)
hist(omegaT(cspks),20); 
p = signrank(omegaT(cspks));
title(['Cspks, time, p = ' num2str(p)])








