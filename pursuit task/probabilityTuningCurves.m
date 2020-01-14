% Probability Tuning curves
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

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
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparison_window = 100:300; % for TC

ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [0:45:180];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    [TC,~,h(ii)] = getTC(data, directions,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, directions);
    TCpop(ii,:) = circshift(TC,5-indPD);
    
    task_info(lines(ii)).directionally_tuned = h(ii);
    task_info(lines(ii)).PD = PD;
    data.info.PD = PD;
    data.info.directionally_tuned = h(ii);
    save (cells{ii},'data');
    
    
    
    % rotate tuning curves
    TC_High(ii,:) =  circshift(getTC(data, directions,inxHigh, comparison_window),5-indPD)-mean(TCpop(ii,:));
    TC_Low(ii,:)= circshift(getTC(data, directions, inxLow, comparison_window),5-indPD)-mean(TCpop(ii,:));
    
    
    for d = 1:length(angles)
        
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        psth_High(ii,d,:) = raster2psth(raster_High,raster_params)-mean(TCpop(ii,:));
        psth_Low(ii,d,:) = raster2psth(raster_Low,raster_params)-mean(TCpop(ii,:));
        
    end
    
    
end


save ('C:\noga\TD complex spike analysis\task_info','task_info');


figure;
ind = find(~h);
subplot(2,1,1)
aveHigh = nanmean(TC_High(ind,:));
semHigh = nanstd(TC_High(ind,:))/sqrt(length(ind));
aveLow = nanmean(TC_Low(ind,:));
semLow = nanstd(TC_Low(ind,:))/sqrt(length(ind));
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Untuned, n = ' num2str(length(ind))]);

ind = find(h);
subplot(2,1,2)
aveHigh = nanmean(TC_High(ind,:));
semHigh = nanstd(TC_High(ind,:))/sqrt(length(ind));
aveLow = nanmean(TC_Low(ind,:));
semLow = nanstd(TC_Low(ind,:))/sqrt(length(ind));
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Significantly tuned, n = ' num2str(sum(h))]);
xlabel('direction')
legend('25', '75')


figure;
ind = find(~h);
for d = 1:length(angles)
    subplot(2,5,d)
    ave_Low = mean(squeeze(psth_Low(ind,d,:)));
    sem_Low = std(squeeze(psth_Low(ind,d,:)))/sqrt(length(ind));
    ave_High = mean(squeeze(psth_High(ind,d,:)));
    sem_High = std(squeeze(psth_High(ind,d,:)))/sqrt(length(ind));
    errorbar(ts,ave_Low,sem_Low,'r'); hold on
    errorbar(ts,ave_High,sem_High,'b'); hold on
    if d==1
        ylimits = get(gca,'YLim')
    end
    ylim([ylimits])
    
end
title(['Not Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')
legend('PD, High','PD, Low', 'Null, High','Null, Low')

ind = find(h);
for d = 1:length(angles)
    subplot(2,5,5+d)
    ave_Low = mean(squeeze(psth_Low(ind,d,:)));
    sem_Low = std(squeeze(psth_Low(ind,d,:)))/sqrt(length(ind));
    ave_High = mean(squeeze(psth_High(ind,d,:)));
    sem_High = std(squeeze(psth_High(ind,d,:)))/sqrt(length(ind));
    errorbar(ts,ave_Low,sem_Low,'r'); hold on
    errorbar(ts,ave_High,sem_High,'b'); hold on
    if d==1
        ylimits = get(gca,'YLim')
    end
    ylim([ylimits])
    
end
title([' Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')
legend('PD, High','PD, Low', 'Null, High','Null, Low')


%%
repeats = 1000;
meanSquares = nan(1,repeats);

trueMeanSquares = mean((aveHigh-aveLow).^2);
for ii=1:repeats
    switch_ind = find(randi([0, 1], [1, length(cells)*length(directions)]));
    
    BS_High = TC_High;
    BS_High (switch_ind) = TC_Low(switch_ind);
    ave_BS_High = nanmean(BS_High);
    
    BS_Low = TC_Low;
    BS_Low (switch_ind) = TC_High(switch_ind);
    ave_BS_Low = mean(BS_Low);
    
    meanSquares(ii) = nanmean((ave_BS_Low-ave_BS_High).^2);
    
    
end

1-invprctile(meanSquares,trueMeanSquares)/100

TC_High_sig = TC_High(find(h),:);
TC_Low_sig = TC_Low(find(h),:);

meanSquares = nan(1,repeats);
trueMeanSquares = mean((nanmean(TC_High_sig)-nanmean(TC_Low_sig)).^2);
for ii=1:repeats
    switch_ind = find(randi([0, 1], [1, sum(h)*length(directions)]));
    
    BS_High = TC_High_sig;
    BS_High (switch_ind) = TC_Low_sig(switch_ind);
    ave_BS_High = nanmean(BS_High);
    
    BS_Low = TC_Low_sig;
    BS_Low (switch_ind) = TC_High_sig(switch_ind);
    ave_BS_Low = nanmean(BS_Low);
    
    meanSquares(ii) = nanmean((ave_BS_Low-ave_BS_High).^2);
    
    
end

1-invprctile( meanSquares,trueMeanSquares)/100


%% reward significanse around PD


clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

comparison_window = 100:300; % for TC


ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [-45,0,45];
lines = findLinesInDB (task_info, req_params);
ind  = find([task_info(lines).directionally_tuned]);
lines = lines(ind);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});

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
    
    rateHigh(ii) = mean(mean(raster_High));
    rateLow(ii) = mean(mean(raster_Low));
    

    
    
    
end

%% Checking the contribution of the eye velocity to the reward difference

clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';


req_params.grade = 7;
req_params.cell_type = 'CRB';
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
clear all
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');
MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';


req_params.grade = 7;
req_params.cell_type = 'CRB';
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

subplot(1,2,2)
ind = find(h);
scatter(rateHigh(ind),rateLow(ind),'b'); 
hold on
refline(1,0)
title('All cells')
signrank(rateHigh(ind),rateLow(ind)) 
scatter(rateHigh(ind),correctedLow(ind),'k'); refline(1,0)
signrank(rateHigh(ind),correctedLow(ind)) 
