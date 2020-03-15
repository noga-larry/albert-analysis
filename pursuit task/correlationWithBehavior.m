clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

behavior_params.time_after = 300;
behavior_params.time_before = 100;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [0:45:180];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

comparison_window = (100:300);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    TCHigh = getTC(data, directions,inxHigh, comparison_window);
    TCLow = getTC(data, directions,inxLow, comparison_window);
    
    spikesHigh = [];
    spikesLow = [];
    velHigh = [];
    velLow = [];
    for d = 1:length(directions)
        
        inx = find (match_d == directions(d)|(~boolFail));

        rasterHigh = getRaster(data,intersect(inx,inxHigh), raster_params);
        rasterLow = getRaster(data, intersect(inx,inxLow), raster_params);
        spikesHigh = [spikesHigh, mean(rasterHigh)*1000 - TCHigh(d)];
        spikesLow = [spikesLow, mean(rasterLow)*1000 - TCLow(d)];
        
        [Have,Vave,hVel,vVel] = meanVelocitiesRotated(data,behavior_params,intersect(inx,inxHigh));
        velHigh = [velHigh,nanmean(hVel-Have,2)'];
        [Have,Vave,hVel,vVel] = meanVelocitiesRotated(data,behavior_params,intersect(inx,inxLow));
        velLow = [velLow,nanmean(hVel-Have,2)'];
        
       
    end
     correlationHigh(ii) = corr(spikesHigh',velHigh');
     correlationLow(ii) = corr(spikesLow',velLow');
    
    
end


figure;
scatter(correlationHigh,correlationLow)
signrank(correlationHigh,correlationLow)

refline(1,0)
xlabel('High'); ylabel('Low')


%% shuffel data

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.allign_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

behavior_params.time_after = 300;
behavior_params.time_before = 100;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [0:45:180];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

comparison_window = (100:300);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    TCHigh = getTC(data, directions,inxHigh, comparison_window);
    TCLow = getTC(data, directions,inxLow, comparison_window);
    
    spikesHigh = [];
    spikesLow = [];
    velHigh = [];
    velLow = [];
    for d = 1:length(directions)
        
        inx = find (match_d == directions(d)|(~boolFail));

        rasterHigh = getRaster(data,intersect(inx,inxHigh), raster_params);
        rasterLow = getRaster(data, intersect(inx,inxLow), raster_params);
        spikesHigh = [spikesHigh, mean(rasterHigh)*1000 - TCHigh(d)];
        spikesLow = [spikesLow, mean(rasterLow)*1000 - TCLow(d)];
        
        [Have,Vave,hVel,vVel] = meanVelocitiesRotated(data,behavior_params,intersect(inx,inxHigh));
        velHigh = [velHigh,nanmean(hVel-Have,2)'];

        [Have,Vave,hVel,vVel] = meanVelocitiesRotated(data,behavior_params,intersect(inx,inxLow));
        velLow = [velLow,nanmean(hVel-Have,2)'];

        
        
    end
    velHigh = velHigh(randperm(length(velHigh)));
    velLow = velLow(randperm(length(velLow)));
    
    
    correlationHigh(ii) = corr(spikesHigh',velHigh');
    correlationLow(ii) = corr(spikesLow',velLow');
     
end


figure;
scatter(correlationHigh,correlationLow)
signrank(correlationHigh,correlationLow)

refline(1,0)
xlabel('High'); ylabel('Low')

