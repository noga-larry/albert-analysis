%% Behavior figure

clear

[task_info,supPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
%req_params.ID = setdiff([5600:6000],[5574,5575]);
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks =1;

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);
DIRECTIONS = [0:45:315];
for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    
    cellID(ii) = data.info.cell_ID;
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    [~,match_d] = getDirections (data);
        
    for d=1:length(DIRECTIONS)
        indLow = find (match_p == 25 & (~boolFail) & match_d==DIRECTIONS(d));
        indHigh = find (match_p == 75 & (~boolFail)& match_d==DIRECTIONS(d));
        
        [RT,Len,OverShoot,Vel] = saccadeRTs(data,indLow);
        RTLow(ii,d) = nanmean(RT);
        LenLow(ii,d) = nanmean(Len);
        OverShootLow(ii,d) = nanmean(OverShoot)-10;
        VelLow(ii,d) = nanmean(Vel);
        
        [RT,Len,OverShoot,Vel] = saccadeRTs(data,indHigh);
        RTHigh(ii,d) = nanmean(RT);
        LenHigh(ii,d) = nanmean(Len);
        OverShootHigh(ii,d) = nanmean(OverShoot)-10;
        VelHigh(ii,d) = nanmean(Vel);
        
        

    end     
    % RT STD
    RT = saccadeRTs(data,find(~boolFail));
    RT_std(ii) = nanstd(RT);
    RT_ave(ii) = nanmean(RT);
end

%%

ind = find(cellID > 5000);
figure;
subplot(2,2,1)
aveLow = nanmean(RTLow(ind,:));
semLow = nanSEM(RTLow(ind,:));
aveHigh = nanmean(RTHigh(ind,:));
semHigh = nanSEM(RTHigh(ind,:));

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(DIRECTIONS)
ylabel('RT')
xlabel('Direction')
legend('25','75')
title('RT')
subplot(2,2,2)
aveLow = nanmean(LenLow(ind,:));
semLow = nanSEM(LenLow(ind,:));
aveHigh = nanmean(LenHigh(ind,:));
semHigh = nanSEM(LenHigh(ind,:));

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(DIRECTIONS)
ylabel('Saccade length')
xlabel('Direction')
legend('25','75')
title('Duration')
subplot(2,2,3)
aveLow = nanmean(VelLow(ind,:));
semLow = nanSEM(VelLow(ind,:));
aveHigh = nanmean(VelHigh(ind,:));
semHigh = nanSEM(VelHigh(ind,:));

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(DIRECTIONS)
ylabel('Vel (deg/s)')
xlabel('Direction')
legend('25','75')
title('Velocity on the target direction')
subplot(2,2,4)
aveLow = nanmean(OverShootLow(ind,:));
semLow = nanSEM(OverShootLow(ind,:));
aveHigh = nanmean(OverShootHigh(ind,:));
semHigh = nanSEM(OverShootHigh(ind,:));

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

ylabel('overshoot (deg)')
xlabel('Direction')
legend('25','75')
title('Overshoot')

figure;
subplot(2,2,1)
scatter(mean(RTHigh(ind,:),2),mean(RTLow(ind,:),2))
refline(1,0)
p = signrank(mean(RTHigh(ind,:),2),mean(RTLow(ind,:),2))
title(['RT: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,2)
scatter(mean(LenHigh(ind,:),2),mean(LenLow(ind,:),2))
refline(1,0)
p = signrank(mean(LenHigh(ind,:),2),mean(LenLow(ind,:),2))
title(['Len: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,3)
scatter(nanmean(VelHigh(ind,:),2),nanmean(VelLow(ind,:),2))
refline(1,0)
p = signrank(nanmean(VelHigh(ind,:),2),nanmean(VelLow(ind,:),2))
title(['Vel: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,4)
scatter(nanmean(OverShootHigh(ind,:),2),nanmean(OverShootLow(ind,:),2))
refline(1,0)
p = signrank(nanmean(OverShootHigh(ind,:),2),nanmean(OverShootLow(ind,:),2))
title(['Over Shoot: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

%% by previous cond

clear 

DIRECTIONS = [0:45:315];

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks =0;



lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
cellID = nan(length(cells),1);

RTLow = nan(length(cells),length(DIRECTIONS),4);
RTHigh= nan(length(cells),length(DIRECTIONS),4);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellID(ii) = data.info.cell_ID;
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome(data);
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail]; % | ~[data.trials.previous_completed];
    boolFail(1) = 1; % Do not use first trial
    
    previous_trial = nan(1,length(data.trials));
    
    for t=2:length(data.trials)
        
        if match_p(t-1) == 25 & match_o(t-1) == 0
            previous_trial(t) = 1;
        elseif match_p(t-1) == 25 & match_o(t-1) == 1
            previous_trial(t) = 2;
        elseif match_p(t-1) == 75 & match_o(t-1) == 0
            previous_trial(t) = 3;
        elseif match_p(t-1) == 75 & match_o(t-1) == 1
            previous_trial(t) = 4;
        end
    end
       
    for d = 1:length(DIRECTIONS)
        for t = 1:4
            indLow = find (match_p == 25 & (~boolFail)....
                & previous_trial==t & match_d == DIRECTIONS(d));
            indHigh = find (match_p == 75 & (~boolFail)...
                & previous_trial==t & match_d == DIRECTIONS(d));
            if ~isempty(indLow)
                RTLow(ii,d,t) = nanmean(saccadeRTs(data,indLow));
            else
                disp(['Skipped: '  num2str(cellID(ii)) ', ' num2str(t) ', Low'])
            end
            if ~isempty(indHigh)
                RTHigh(ii,d,t) = nanmean(saccadeRTs(data,indHigh));
            else
                disp(['Skipped: '  num2str(cellID(ii)) ', ' num2str(t) ', High'])
            end
        end 
    end
end

%%
figure
ind = find(cellID<5000);

subplot(2,1,1); hold on
for t = 1:4
    ave = squeeze(nanmean(RTLow(ind,:,t)));
    sem = squeeze(nanSEM(RTLow(ind,:,t)));
    errorbar(DIRECTIONS,ave,sem)
end
title('Current 25')

subplot(2,1,2); hold on
for t = 1:4
    ave = squeeze(nanmean(RTHigh(ind,:,t)));
    sem = squeeze(nanSEM(RTHigh(ind,:,t)));
    errorbar(DIRECTIONS,ave,sem)
end
title('Current 75')
legend('Previous 25NR', 'Previous 25R', 'Previous 75NR', 'Previous 75R')


figure
subplot(2,2,1)
com1 = squeeze(RTLow(ind,:,1));
com2 = squeeze(RTLow(ind,:,2));
scatter(com1,com2)
p = signrank(com1(:),com2(:));
refline(1,0)
xlabel('Previous 25NR'); ylabel('Previous 25R')
title(['25 in this trial, p =' num2str(p)])

subplot(2,2,2)
com1 = squeeze(RTLow(ind,:,3));
com2 = squeeze(RTLow(ind,:,4));
scatter(com1,com2)
p = signrank(com1(:),com2(:));
refline(1,0)
xlabel('Previous 75NR'); ylabel('Previous 75R')
title(['25 in this trial, p =' num2str(p)])

subplot(2,2,3)
com1 = squeeze(RTHigh(ind,:,1));
com2 = squeeze(RTHigh(ind,:,2));
scatter(com1,com2)
p = signrank(com1(:),com2(:));
refline(1,0)
xlabel('Previous 25NR'); ylabel('Previous 25R')
title(['75 in this trial, p =' num2str(p)])

subplot(2,2,4)
com1 = squeeze(RTHigh(ind,:,3));
com2 = squeeze(RTHigh(ind,:,4));
scatter(com1,com2)
p = signrank(com1(:),com2(:));
refline(1,0)
xlabel('Previous 75NR'); ylabel('Previous 75R')
title(['75 in this trial, p =' num2str(p)])

%% Frection of previous trial failures

clear

PROBABILITEIS = [25, 75];

[task_info,supPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
%req_params.ID = setdiff([5600:6000],[5574,5575]);
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks =1;

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    
    cellID(ii) = data.info.cell_ID;
    [~,match_p] = getProbabilities (data);
    
    
    
    for p = 1:length(PROBABILITEIS)
        ind = find(~[data.trials.fail] & match_p == PROBABILITEIS(p));
        frac(ii,p) = mean([data.trials(ind).previous_completed]);
    end
end

%% 
figure;
subplot(2,1,1)
ind = find(cellID>5000);
scatter(frac(ind,2),frac(ind,1))
refline(1,0)
p = signrank(frac(ind,2),frac(ind,1));
title(['Golda: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')


subplot(2,1,2)
ind = find(cellID<5000);
scatter(frac(ind,2),frac(ind,1))
refline(1,0)
p = signrank(frac(ind,2),frac(ind,1));
title(['Albert: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')


