clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';


req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
raster_params.SD = 10;

comparison_window = raster_params.time_before + (100:300); % for TC

behavior_params.time_after = 250;
behavior_params.time_before = -200;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms


ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [-45,0,45];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    PD = data.info.PD;
    
    boolDir = (match_d == mod(PD+angles(1),360)) |...
        (match_d == mod(PD+angles(2),360)) |...
        (match_d == mod(PD+angles(3),360));
    
    inx = find (boolDir & (~boolFail));
    
    raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
    raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
    
    rateHigh(ii) = mean(mean(raster_High(comparison_window,:)))*1000;
    rateLow(ii) = mean(mean(raster_Low(comparison_window,:)))*1000;
    
    velHigh(ii) = mean(meanVelocitiesRotated(data,behavior_params,intersect(inx,inxHigh)));
    velLow(ii) = mean(meanVelocitiesRotated(data,behavior_params,intersect(inx,inxLow)));
    
    
end

figure;scatter(rateHigh,rateLow); refline(1,0)
xlabel('75'); ylabel('25')
signrank(rateHigh,rateLow)

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';


req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
raster_params.SD = 10;

comparison_window = raster_params.time_before + (100:300); % for TC

behavior_params.time_after = 250;
behavior_params.time_before = -200;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms


ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [-45,0,45];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    PD = data.info.PD;
    h(ii)= data.info.directionally_tuned;
    
    boolDir = (match_d == mod(PD+angles(1),360)) |...
        (match_d == mod(PD+angles(2),360)) |...
        (match_d == mod(PD+angles(3),360));
    
    inx = find (boolDir & (~boolFail));
    
    raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
    raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
    
    rateHigh(ii) = mean(mean(raster_High(comparison_window,:)))*1000;
    rateLow(ii) = mean(mean(raster_Low(comparison_window,:)))*1000;
    
    velHigh(ii) = mean(meanVelocitiesRotated(data,behavior_params,intersect(inx,inxHigh)));
    velLow(ii) = mean(meanVelocitiesRotated(data,behavior_params,intersect(inx,inxLow)));
    
    
end

%%
correctedLow = rateLow.*(velHigh./velLow);

figure;
subplot(1,2,1)
scatter(rateHigh,rateLow,'b'); 
hold on
refline(1,0)
title('All cells')
signrank(rateHigh,rateLow) 
scatter(rateHigh,correctedLow,'k'); refline(1,0)
signrank(rateHigh,correctedLow) 
xlabel('75'); ylabel('25')

subplot(1,2,2)
ind = find(h);
scatter(rateHigh(ind),rateLow(ind),'b'); 
hold on
refline(1,0)
title('Tuned cells')
signrank(rateHigh(ind),rateLow(ind)) 
scatter(rateHigh(ind),correctedLow(ind),'k'); refline(1,0)
signrank(rateHigh(ind),correctedLow(ind)) 
xlabel('75'); ylabel('25')



