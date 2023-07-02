%% Behavior figure

clear

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

SINGLE_SESSION = false;
PROBABITIES = [25,75];
COL ={'r','b'}';
SCATTER_TIME = 200:250;
MONKEY = "both";

req_params = reqParamsEffectSize("pursuit",MONKEY);

behavior_params.time_after = 1000;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 20; % ms

SCATTER_TIME = -behavior_params.time_before + SCATTER_TIME;

ts = -behavior_params.time_before:behavior_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


vel = nan(length(cells),length(PROBABITIES),length(ts));
numCorrective = nan(length(cells),length(PROBABITIES));


for ii = 1:length(cells)

    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];

    if SINGLE_SESSION
        cla;hold on
    end
    for p=1:length(PROBABITIES)
        ind = find (match_p == PROBABITIES(p) & (~boolFail));

        vel(ii,p,:) = meanVelocitiesRotated(data,behavior_params,...
            ind,'removeSaccades',true);
        
        numCorrective(ii,p) = mean(numCorrectiveSaccades(data,ind));

        if SINGLE_SESSION

            [~,~,h,~] = ...
                meanPositionsRotated(data,behavior_params,ind(10:20),...
                'smoothIndividualTrials',true,'removeSaccades',false);
            plot(h',COL{p})

        end
    end

    if SINGLE_SESSION
        pause
    end
end

ave = squeeze(mean(vel,1));
sem = squeeze(nanSEM(vel,1));


figure;
subplot(2,1,1); hold on
for p=1:length(PROBABITIES)
    errorbar(ts,ave(p,:),sem(p,:),COL{p}); hold on
end

subplot(2,1,2); hold on
scatter(numCorrective(:,2),numCorrective(:,1))
p = signrank(numCorrective(:,1),numCorrective(:,2));


xlabel('High');ylabel('Low')
refline(1,0)
title(['number of corrective saccades, p = ' num2str(p) 'n = ' num2str(length(cells))])

sgtitle(MONKEY)
%%
figure
scatter(mean(vel(:,2,SCATTER_TIME),3),mean(vel(:,1,SCATTER_TIME),3))
p = signrank(mean(vel(:,2,SCATTER_TIME),3),mean(vel(:,1,SCATTER_TIME),3));

xlabel('High');ylabel('Low')
refline(1,0)
title(['p = ' num2str(p) 'n = ' num2str(length(cells))])
%% Seperated by direction

clear 

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("pursuit","golda");

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 20; % ms

SCATTER_TIME = -behavior_params.time_before + 200:250;

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
figure
errorbar(DIRECTIONS,nanmean(mean(velHigh(:,:,SCATTER_TIME),3)),nanSEM(mean(velHigh(:,:,SCATTER_TIME),3)),'b');
hold on
errorbar(DIRECTIONS,nanmean(mean(velLow(:,:,SCATTER_TIME),3)),nanSEM(mean(velLow(:,:,SCATTER_TIME),3)),'r')
xlabel('Vel');ylabel('Direction 200:25 ms')
legend('P=75','P=25')


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



