%% Behavior figure

clear 

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

SINGLE_SESSION = false;

req_params = reqParamsEffectSize("pursuit");

behavior_params.time_after = 1000;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

h = figure;
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    velLow(ii,:) = meanVelocitiesRotated(data,behavior_params,...
        indLow,'removeSaccades',true);
    velHigh(ii,:) = meanVelocitiesRotated(data,behavior_params,...
        indHigh,'removeSaccades',true);
    
    
    if SINGLE_SESSION
        cla;hold on
        [~,~,hVel,~] = ...
            meanPositionsRotated(data,behavior_params,indLow(10:20),...
            'smoothIndividualTrials',true,'removeSaccades',false);
        plot(hVel','r')
                [~,~,hVel,~] = ...
            meanPositionsRotated(data,behavior_params,indHigh(10:20),...
            'smoothIndividualTrials',true,'removeSaccades',false);
        plot(hVel','b')
        pause
    end
end

aveLow = mean(velLow,1);
semLow = nanSEM(velLow,1);
aveHigh = mean(velHigh,1);
semHigh = nanSEM(velHigh,1);

errorbar(aveLow,semLow,'r'); hold on
errorbar(aveHigh,semHigh,'b')
%%
figure
scatter(mean(velHigh(:,200:250),2),mean(velLow(:,200:250),2))
p = signrank(mean(velHigh(:,200:250),2),mean(velLow(:,200:250),2));


xlabel('High');ylabel('Low')
refline(1,0)
title(['p = ' num2str(p) 'n = ' num2str(length(cells))])
%% Seperated by direction

clear 

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("pursuit");

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

DIRECTIONS = 0:45:315;

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);

    cellID(ii) = data.info.cell_ID;


    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    for d=1:length(DIRECTIONS)
        indDir = find(match_d==DIRECTIONS(d));
        velLow(ii,d,:) = meanVelocitiesRotated(data,behavior_params,intersect(indLow,indDir));
        velHigh(ii,d,:) = meanVelocitiesRotated(data,behavior_params,intersect(indHigh,indDir));
    end
    
end
%%

ind = find(cellID < 5000);

figure
errorbar(DIRECTIONS,nanmean(mean(velHigh(ind,:,200:250),3)),nanSEM(mean(velHigh(ind,:,200:250),3)),'b');
hold on
errorbar(DIRECTIONS,nanmean(mean(velLow(ind,:,200:250),3)),nanSEM(mean(velLow(ind,:,200:250),3)),'r')
xlabel('Vel');ylabel('Direction 200:25 ms')
legend('P=25','P=75')


%% by previous cond


clear 

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
ts = -behavior_params.time_before:behavior_params.time_after;
cellID = nan(length(cells),1);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellID(ii) = data.info.cell_ID;
    
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome(data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
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
    
    for t = 1:4
        indLow = find (match_p == 25 & (~boolFail) & previous_trial==t);
        indHigh = find (match_p == 75 & (~boolFail)& previous_trial==t);
        velLow(ii,t,:) = meanVelocitiesRotated(data,behavior_params,indLow);
        velHigh(ii,t,:) = meanVelocitiesRotated(data,behavior_params,indHigh);
    end
    
end

%%

ind = find(cellID<10000);
aveLow = squeeze(nanmean(velLow(ind,:,:),1));
semLow = squeeze(nanSEM(velLow(ind,:,:),1));
aveHigh = squeeze(nanmean(velHigh(ind,:,:),1));
semHigh = squeeze(nanSEM(velHigh(ind,:,:),1));

figure;
subplot(2,2,1)
errorbar(aveLow',semLow');
title('25 in this trial')
subplot(2,2,2)
errorbar(aveHigh',semHigh');
title('75 in this trial')

legend('25NR','25R','75NR','75R')

subplot(2,2,3)
scatter(mean(mean(velLow(ind,[1,4],200:250),3),2),mean(mean(velLow(ind,[2,3],200:250),3),2))
p = signrank(mean(mean(velLow(ind,[1,4],200:250),3),2),mean(mean(velLow(ind,[2,3],200:250),3),2));
xlabel('25NR+75R'); ylabel('25R+75NR')
title(['25 in this trial, p =' num2str(p)])
equalAxis(); refline(1,0)
subplot(2,2,4)
scatter(mean(mean(velHigh(ind,[1,4],200:250),3),2),mean(mean(velHigh(ind,[2,3],200:250),3),2))
p = signrank(mean(mean(velHigh(ind,[1,4],200:250),3),2),mean(mean(velHigh(ind,[2,3],200:250),3),2));
xlabel('25NR+75R'); ylabel('25R+75NR')
title(['25 in this trial, p =' num2str(p)])
equalAxis(); refline(1,0)

%%

figure
ind = find(cellID<5000);

subplot(2,2,1)
scatter(mean(mean(velLow(ind,1,200:250),3),2),mean(mean(velLow(ind,2,200:250),3),2))
p = signrank(mean(mean(velLow(ind,1,200:250),3),2),mean(mean(velLow(ind,2,200:250),3),2));
refline(1,0)
xlabel('Previous 25NR'); ylabel('Previous 25R')
title(['25 in this trial, p =' num2str(p)])

subplot(2,2,2)
scatter(mean(mean(velLow(ind,3,200:250),3),2),mean(mean(velLow(ind,4,200:250),3),2))
p = signrank(mean(mean(velLow(ind,3,200:250),3),2),mean(mean(velLow(ind,4,200:250),3),2));
refline(1,0)
xlabel('Previous 75NR'); ylabel('Previous 75R')
title(['25 in this trial, p =' num2str(p)])

subplot(2,2,3)
scatter(mean(mean(velHigh(ind,1,200:250),3),2),mean(mean(velHigh(ind,2,200:250),3),2))
p = signrank(mean(mean(velHigh(ind,1,200:250),3),2),mean(mean(velHigh(ind,2,200:250),3),2));
refline(1,0)
xlabel('Previous 25NR'); ylabel('Previous 25R')
title(['75 in this trial, p =' num2str(p)])

subplot(2,2,4)
scatter(mean(mean(velHigh(ind,3,200:250),3),2),mean(mean(velHigh(ind,4,200:250),3),2))
p = signrank(mean(mean(velHigh(ind,3,200:250),3),2),mean(mean(velHigh(ind,4,200:250),3),2));
refline(1,0)
xlabel('Previous 75NR'); ylabel('Previous 75R')
title(['75 in this trial, p =' num2str(p)])