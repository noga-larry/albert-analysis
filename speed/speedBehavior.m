%% Behavior figure

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\speed_2_dir_0,50,100';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000;
req_params.num_trials = 60;
req_params.remove_question_marks =0;

behavior_params.time_after = 400;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

cells = findPathsToCells (supPath,task_info,req_params);

velocities = [25,15];

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);    
    [~,match_v] = getVelocities (data);
    boolFail = [data.trials.fail];

    
    for v = 1:length(velocities)
        
        boolVel = (match_v == velocities(v));
        
        indLow = find (match_p == 0 & (~boolFail) & boolVel);
        indMid = find (match_p == 50 & (~boolFail) & boolVel);
        indHigh = find (match_p == 100 & (~boolFail) & boolVel);
        
        velLow(ii,v,:) = meanVelocitiesRotated(data,behavior_params,indLow);
        velMid(ii,v,:) = meanVelocitiesRotated(data,behavior_params,indMid);
        velHigh(ii,v,:) = meanVelocitiesRotated(data,behavior_params,indHigh);
    end
    
end


for v = 1:length(velocities)
    
    aveLow = mean(squeeze(velLow(:,v,:)));
    semLow = std(squeeze(velLow(:,v,:)))/sqrt(length(cells));
    aveMid = mean(squeeze(velMid(:,v,:)));
    semMid = std(squeeze(velMid(:,v,:)))/sqrt(length(cells));
    aveHigh = mean(squeeze(velHigh(:,v,:)));
    semHigh = std(squeeze(velHigh(:,v,:)))/sqrt(length(cells));
    
    subplot(1,2,v)
    errorbar(aveLow,semLow,'r'); hold on
    errorbar(aveMid,semMid,'k')
    errorbar(aveHigh,semHigh,'b')
    
    ylim([-2 30])
    title ([ 'velocity = ' num2str(velocities(v))])
    legend ('0', '50','100')
end