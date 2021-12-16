%% Behavior figure

clear 

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 50;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    velLow(ii,:) = meanVelocitiesRotated(data,behavior_params,indLow);
    velHigh(ii,:) = meanVelocitiesRotated(data,behavior_params,indHigh);
    
end

aveLow = mean(velLow);
semLow = std(velLow)/sqrt(length(cells));
aveHigh = mean(velHigh);
semHigh = std(velHigh)/sqrt(length(cells));

figure
errorbar(aveLow,semLow,'r'); hold on
errorbar(aveHigh,semHigh,'b')

figure
scatter(mean(velHigh(:,200:250),2),mean(velLow(:,200:250),2))
xlabel('High');ylabel('Low')
refline(1,0)

%% Seperated by direction

clear all

MaestroPath = 'C:\Users\Noga\Music\DATA\';
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 100;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

directions = 0:45:315;

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    for d=1:length(directions)
        indDir = find(match_d==directions(d));
        velLow(ii,d,:) = meanVelocitiesRotated(data,behavior_params,intersect(indLow,indDir));
        velHigh(ii,d,:) = meanVelocitiesRotated(data,behavior_params,intersect(indHigh,indDir));
    end
    
end


figure
errorbar(directions,nanmean(mean(velHigh(:,:,200:250),3)),nanstd(mean(velHigh(:,:,200:250),3))/sqrt(length(cells)),'b');
hold on
errorbar(directions,nanmean(mean(velLow(:,:,200:250),3)),nanstd(mean(velLow(:,:,200:250),3))/sqrt(length(cells)),'r')
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

ind = find(cellID<5000)
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
