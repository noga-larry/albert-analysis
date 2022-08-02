% Probability Tuning curves
clear; clc; close all
[task_info, supPath ,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;
req_params.ID = 4000:6000;


raster_params.align_to = 'targetMovementOnset';
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



cell_ID = [];
for ii = 1:length(cells)
    data = importdata(cells{ii});
    cell_ID  = [cell_ID,data.info.cell_ID];
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    % match_d = permVec(match_d);
    
    [TC,~,h(ii)] = getTC(data, directions,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, directions);
    TCpop(ii,:) = circshift(TC,5-indPD);
    
    task_info(lines(ii)).directionally_tuned = h(ii);
    task_info(lines(ii)).PD = PD;
    data.info.PD = PD;
    data.info.directionally_tuned = h(ii);
    save (cells{ii},'data');
    
    baseline = mean(getPSTH(data,find(~boolFail),raster_params));
    
    if strcmp(req_params.cell_type,'PC cs')
        baseline = 0;
    end
    
    % rotate tuning curves
    TC_High(ii,:) =  circshift(getTC(data, directions,inxHigh, comparison_window),5-indPD)-baseline;
    TC_Low(ii,:)= circshift(getTC(data, directions, inxLow, comparison_window),5-indPD)-baseline;
   
   
    for d = 1:length(angles)
        
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        
        psth_High(ii,d,:) = raster2psth(raster_High,raster_params) - baseline;
        psth_Low(ii,d,:) = raster2psth(raster_Low,raster_params)- baseline;
        
    end
    
    
end


save (task_DB_path,'task_info')


angle_for_glm = -180:45:0;

k = length(angle_for_glm);
ind = find(h);

for ii=1:length(ind)
    cell_ID_for_GLM((2*k)*(ii-1)+1:(2*k)*ii) = cell_ID(ind(ii));
    reward_for_GLM((2*k)*(ii-1)+1:(2*k)*(ii-1)+k) = 25;
    reward_for_GLM((2*k)*(ii-1)+(k+1):(2*k)*(ii-1)+(2*k)) = 75;
    angle_for_GLM((2*k)*(ii-1)+1:(2*k)*(ii-1)+k) = angle_for_glm;
    angle_for_GLM((2*k)*(ii-1)+(k+1):(2*k)*(ii-1)+(2*k)) = angle_for_glm;
    response_for_GLM((2*k)*(ii-1)+1:(2*k)*(ii-1)+k) = (TC_Low(ind(ii),1:5)+TC_Low(ind(ii),[1,8:-1:5]))/2;
    response_for_GLM((2*k)*(ii-1)+(k+1):(2*k)*(ii-1)+(2*k)) = (TC_High(ind(ii),1:5)+TC_High(ind(ii),[1,8:-1:5]))/2;
end

glm_tbl = table(cell_ID_for_GLM',reward_for_GLM',angle_for_GLM',...
    response_for_GLM','VariableNames',{'ID','reward','angle_from_PD','response'});
glme = fitglme(glm_tbl,...
'response ~ 1 + angle_from_PD + reward  +  angle_from_PD *reward + (1|ID)')



directions = [-180:45:180];
f = figure; f.Position = [10 80 700 500];

ind = find(h);
subplot(3,1,2)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanSEM(TC_High(ind,:)),nanSEM(TC_High(ind,1))];
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanSEM(TC_Low(ind,:)), nanSEM(TC_Low(ind,1))];
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Significantly tuned, n = ' num2str(sum(h))]);
xlabel('direction')
legend( '25','75')
ylimits = get(gca,'YLim');

ind = find(~h);
subplot(3,1,1)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanSEM(TC_High(ind,:)),nanSEM(TC_High(ind,1))];
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanSEM(TC_Low(ind,:)), nanSEM(TC_Low(ind,1))];
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Untuned, n = ' num2str(length(ind))]);
ylim([ylimits])


ind = 1:length(cells);
subplot(3,1,3)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanSEM(TC_High(ind,:)),nanSEM(TC_High(ind,1))];
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanSEM(TC_Low(ind,:)), nanSEM(TC_Low(ind,1))];
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['All, n = ' num2str(length(cells))]);
xlabel('direction')
legend( '25','75')
ylim([ylimits])


f = figure; f.Position = [10 80 700 500];

ind = find(~h);
for d = 1:length(angles)
    subplot(3,5,d)
    ave_Low = nanmean(squeeze(psth_Low(ind,d,:)));
    sem_Low = nanSEM(squeeze(psth_Low(ind,d,:)));
    ave_High = mean(squeeze(psth_High(ind,d,:)));
    sem_High = nanSEM(squeeze(psth_High(ind,d,:)));
    errorbar(ts,ave_Low,sem_Low,'r'); hold on
    errorbar(ts,ave_High,sem_High,'b'); hold on
    if d==1
        ylimits = get(gca,'YLim')
    end
    ylim([ylimits])
    legend( '25','75')
end
title(['Not Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')
legend( '25','75')

ind = find(h);
for d = 1:length(angles)
    subplot(3,5,5+d)
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
    legend( '25','75')
    
end
title([' Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')
legend( '25','75')

ind = 1:length(h);
for d = 1:length(angles)
    subplot(3,5,10+d)
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
    legend( '25','75')
    
end
title([' All, n = ' num2str(length(ind))]);
xlabel('Time from movement')
legend( '25','75')

%%

aveHigh = nanmean(TC_High);
aveLow = nanmean(TC_Low);

directions = 0:45:315;

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

 p = 1-invprctile(meanSquares,trueMeanSquares)/100

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
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

angles = [-45,0,45];
lines = findLinesInDB (task_info, req_params);
%ind  = find([task_info(lines).directionally_tuned]);
%lines = lines(ind);
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

figure; 
scatter(rateHigh,rateLow);
refline(1,0)
p = signrank(rateHigh,rateLow);
title(['p = ' num2str(p)])
xlabel('P=75'); ylabel('P=25')
%% reward significanse in different angles around the PD


clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

angles = [0:45:180];
lines = findLinesInDB (task_info, req_params);
%ind  = find([task_info(lines).directionally_tuned]);
%lines = lines(ind);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
    PD = data.info.PD;
    
    for j=1:length(angles)
        boolDir = (match_d == mod(PD+angles(j),360)) |...
            (match_d == mod(PD-angles(j),360));
        
        inx = find (boolDir & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        rateHigh(ii,j) = mean(mean(raster_High));
        rateLow(ii,j) = mean(mean(raster_Low));
    end
 
end

figure; 
for j=1:length(angles)
    subplot(2,ceil(length(angles)/2),j)
    scatter(rateHigh(:,j),rateLow(:,j));
    refline(1,0)
    p = signrank(rateHigh(:,j),rateLow(:,j));
    title(['PD +-' num2str(angles(j)) 'p = ' num2str(p)])
    xlabel('P=75'); ylabel('P=25')
end

%% reward significanse in directions in the world

clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

angles = [0:45:315];
lines = findLinesInDB (task_info, req_params);
%ind  = find([task_info(lines).directionally_tuned]);
%lines = lines(ind);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    inxLow = find (match_p == 25 & (~boolFail));
    inxHigh = find (match_p == 75 & (~boolFail));
    
    [~,match_d] = getDirections(data);
    
  
    for j=1:length(angles)
        boolDir = (match_d == angles(j));
        
        inx = find (boolDir & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        rateHigh(ii,j) = mean(mean(raster_High));
        rateLow(ii,j) = mean(mean(raster_Low));
    end
 
end

figure; 
for j=1:length(angles)
    subplot(2,ceil(length(angles)/2),j)
    scatter(rateHigh(:,j),rateLow(:,j));
    refline(1,0)
    p = signrank(rateHigh(:,j),rateLow(:,j));
    title(['PD +-' num2str(angles(j)) 'p = ' num2str(p)])
    xlabel('P=75'); ylabel('P=25')
end


%% Checking the contribution of the eye velocity to the reward difference

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


raster_params.align_to = 'targetMovementOnset';
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




%%
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


%% Significance in time
clear 
[task_info, supPath] = loadDBAndSpecifyDataPaths('Vermis');

WINDOW_SIZE = 50;
NUM_COMPARISONS = 3; 

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 300;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0; % ms in each side
raster_params.SD = 15;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -(raster_params.time_before - ceil(WINDOW_SIZE/2)): ...
    (raster_params.time_after- ceil(WINDOW_SIZE/2));


for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail];
    
    ind = find(~boolFail);
    
    raster = getRaster(data,ind,raster_params);
    
    func = @(raster) sigFunc(raster,match_p(ind),match_d(ind));
    returnTrace(ii,:,:) = ...
        runningWindowFunction(raster,func,WINDOW_SIZE,NUM_COMPARISONS);

end


figure;
plot(ts,squeeze(mean(returnTrace)))
xlabel('Time from movement')
ylabel('Frac significiant')
legend('75 vs 25','Direction','Interaction')

sgtitle(req_params.cell_type)
%%
function h = sigFunc(raster,match_p,match_d)
% comparison R vs NR

spk = sum(raster);
p = anovan(spk,{match_p,match_d},'model','full','display','off');

h = p'<0.05;

end
