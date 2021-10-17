%% Behavior figure

clear

[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'saccade_8_dir_75and25';
%req_params.ID = setdiff([5600:6000],[5574,5575]);
req_params.ID = 4000:5000;
req_params.num_trials = 70;
req_params.remove_question_marks =1;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);
directions = [0:45:315];
for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    [~,match_d] = getDirections (data);
        
    for d=1:length(directions)
        indLow = find (match_p == 25 & (~boolFail) & match_d==directions(d));
        indHigh = find (match_p == 75 & (~boolFail)& match_d==directions(d));
        
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
    
    
end

%%
figure;
subplot(2,2,1)
aveLow = nanmean(RTLow);
semLow = nanSEM(RTLow);
aveHigh = nanmean(RTHigh);
semHigh = nanSEM(RTHigh);

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(directions)
ylabel('RT')
xlabel('Direction')
legend('25','75')
title('RT')
subplot(2,2,2)
aveLow = nanmean(LenLow);
semLow = nanSEM(LenLow);
aveHigh = nanmean(LenHigh);
semHigh = nanSEM(LenHigh);

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(directions)
ylabel('Saccade length')
xlabel('Direction')
legend('25','75')
title('Duration')
subplot(2,2,3)
aveLow = nanmean(VelLow);
semLow = nanSEM(VelLow);
aveHigh = nanmean(VelHigh);
semHigh = nanSEM(VelHigh)/sqrt(length(cells));

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

xticklabels(directions)
ylabel('Vel (deg/s)')
xlabel('Direction')
legend('25','75')
title('Velocity on the target direction')
subplot(2,2,4)
aveLow = nanmean(OverShootLow);
semLow = nanSEM(OverShootLow);
aveHigh = nanmean(OverShootHigh);
semHigh = nanSEM(OverShootHigh);

errorbar(0:45:315,aveLow,semLow,'r'); hold on
errorbar(0:45:315,aveHigh,semHigh,'b')

ylabel('overshoot (deg)')
xlabel('Direction')
legend('25','75')
title('Overshoot')

figure;
subplot(2,2,1)
scatter(mean(RTHigh,2),mean(RTLow,2))
refline(1,0)
p = signrank(mean(RTHigh,2),mean(RTLow,2))
title(['RT: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,2)
scatter(mean(LenHigh,2),mean(LenLow,2))
refline(1,0)
p = signrank(mean(LenHigh,2),mean(LenLow,2))
title(['Len: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,3)
scatter(nanmean(VelHigh,2),nanmean(VelLow,2))
refline(1,0)
p = signrank(nanmean(VelHigh,2),nanmean(VelLow,2))
title(['Vel: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')

subplot(2,2,4)
scatter(nanmean(OverShootHigh,2),nanmean(OverShootLow,2))
refline(1,0)
p = signrank(nanmean(OverShootHigh,2),nanmean(OverShootLow,2))
title(['Over Shoot: p = ' num2str(p)])
xlabel('P=75')
ylabel('P=25')