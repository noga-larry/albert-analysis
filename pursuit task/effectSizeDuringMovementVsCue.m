clear all
supPath = 'C:\noga\TD complex spike analysis\Data\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_d = match_d(find(~boolFail))';
    
    raster_params.allign_to = 'targetMovementOnset';
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
    omegaT(1,ii) = omega(tbl,2);
    omegaR(1,ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(1,ii) = omega(tbl,4)+omega(tbl,6);
    
    raster_params.allign_to = 'cue';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
        
    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{9,2};
    msw = tbl{8,5};
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(2,ii) = omega(tbl,2);
    omegaR(2,ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(2,ii) = omega(tbl,4)+omega(tbl,6);
    
end

%%
figure;
subplot(3,1,1)
scatter(omegaT(1,:),omegaT(2,:),'filled'); 
p = signrank(omegaT(1,:),omegaT(2,:));
title(['time ,p = ' num2str(p)])
xlabel('movement')
ylabel('cue')
refline(1,0)
 makeSquareAxis()

subplot(3,1,2)
scatter(omegaR(1,:),omegaR(2,:),'filled'); 
p = signrank(omegaR(1,:),omegaR(2,:));
title(['reward,p = ' num2str(p)])
xlabel('movement')
ylabel('cue')
makeSquareAxis()
refline(1,0)


subplot(3,1,3)
scatter(omegaD(1,:),omegaD(2,:),'filled'); 
p = signrank(omegaD(1,:),omegaD(2,:));
title(['direction ,p = ' num2str(p)])
xlabel('movement')
ylabel('cue')
makeSquareAxis()
refline(1,0)




