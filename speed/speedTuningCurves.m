% Probability Tuning curves - regardles of direction 
clear
[task_info, supPath ,~,task_DB_path] = ...
    loadDBAndSpecifyDataPaths('Vermis');

velocities = [15, 25];

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:6000;
req_params.num_trials = 60;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

comparison_window = (100:500) + raster_params.time_before; % for TC

ts = -raster_params.time_before:raster_params.time_after;
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [~,match_v] = getVelocities(data);
    boolFail = [data.trials.fail];
    
    boolLow = (match_p == 0 & (~boolFail));
    boolMid = (match_p == 50 & (~boolFail));
    boolHigh = (match_p == 100 & (~boolFail));
    
    for v = 1:length(velocities)
    
    rasterLow = getRaster(data,find(boolLow & (match_v == velocities(v))), raster_params);
    rasterMid = getRaster(data,find(boolMid & (match_v == velocities(v))), raster_params);
    rasterHigh = getRaster(data,find(boolHigh & (match_v == velocities(v))), raster_params);
    
    rasterBaseline =  getRaster(data,find(~boolFail), raster_params);
    baseline = mean(mean(rasterBaseline))*1000;
    
    if strcmp(req_params.cell_type,'PC cs')
        baseline =0;
    end
    
    TCLow (ii,v) = mean(mean(rasterLow(comparison_window,:)))*1000-baseline;
    TCMid (ii,v) = mean(mean(rasterMid(comparison_window,:)))*1000-baseline;
    TCHigh (ii,v) = mean(mean(rasterHigh(comparison_window,:)))*1000-baseline;
    
    psthLow(ii,v,:) = raster2psth(rasterLow,raster_params)-baseline;
    psthMid(ii,v,:) = raster2psth(rasterMid,raster_params)-baseline;
    psthHigh(ii,v,:) = raster2psth(rasterHigh,raster_params)-baseline;

    end
    
end


figure;

subplot(3,1,1)

aveLow = mean(squeeze(psthLow(:,1,:)));
semLow = nanSEM(squeeze(psthLow(:,1,:)));
errorbar(ts,aveLow,semLow,'c'); hold on
aveLow = mean(squeeze(psthLow(:,2,:)));
semLow = nanSEM(squeeze(psthLow(:,2,:)));
errorbar(ts,aveLow,semLow,'k'); hold on
legend('15','25')

subplot(3,1,2)

aveMid = mean(squeeze(psthMid(:,1,:)));
semMid = nanSEM(squeeze(psthMid(:,1,:)));
errorbar(ts,aveMid,semMid,'c'); hold on
aveMid = mean(squeeze(psthMid(:,2,:)));
semMid = nanSEM(squeeze(psthMid(:,2,:)));
errorbar(ts,aveMid,semMid,'k'); hold on    

subplot(3,1,3)
aveHigh = mean(squeeze(psthHigh(:,1,:)));
semHigh = nanSEM(squeeze(psthHigh(:,1,:)));
errorbar(ts,aveHigh,semHigh,'c'); hold on
aveHigh = mean(squeeze(psthHigh(:,2,:)));
semHigh = nanSEM(squeeze(psthHigh(:,2,:)));
errorbar(ts,aveHigh,semHigh,'k'); hold on


figure;

aveTCLow = mean(TCLow);
aveTCMid = mean(TCMid);
aveTCHigh = mean(TCHigh);

semTCLow = nanSEM(TCLow);
semTCMid = nanSEM(TCMid);
semTCHigh = nanSEM(TCHigh);


errorbar(velocities,aveTCLow,semTCLow,'r'); hold on
errorbar(velocities,aveTCMid,semTCMid,'k');
errorbar(velocities,aveTCHigh,semTCHigh,'b');
legend('0','50','100')


%%

% Probability Tuning curves - taking the PD into consideration
clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

velocities = [15, 25];

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'speed_2_dir_0,50,100';
req_params.ID = 4000:5000;
req_params.num_trials = 60;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

comparison_window = (100:500) + raster_params.time_before; % for TC

ts = -raster_params.time_before:raster_params.time_after;
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)


    
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [~,match_v] = getVelocities(data);
    [directions,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    boolLow = (match_p == 0 & (~boolFail));
    boolMid = (match_p == 50 & (~boolFail));
    boolHigh = (match_p == 100 & (~boolFail));
    
    [~,indShift] = min(abs(directions-PD));
    directions = circshift (directions,1-indShift);
    for d = 1:length(directions)
        for v = 1:length(velocities)
            
            rasterLow = getRaster(data,find(boolLow & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            rasterMid = getRaster(data,find(boolMid & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            rasterHigh = getRaster(data,find(boolHigh & (match_v == velocities(v)) & (match_d == directions(d))), raster_params);
            
            
            rasterBaseline =  getRaster(data,find(~boolFail), raster_params);
            baseline = mean(mean(rasterBaseline))*1000;
            
            TCLow (ii,v,d) = mean(mean(rasterLow(comparison_window,:)))*1000-baseline;
            TCMid (ii,v,d) = mean(mean(rasterMid(comparison_window,:)))*1000-baseline;
            TCHigh (ii,v,d) = mean(mean(rasterHigh(comparison_window,:)))*1000-baseline;
            
            psthLow(ii,v,d,:) = raster2psth(rasterLow,raster_params)-baseline;
            psthMid(ii,v,d,:) = raster2psth(rasterMid,raster_params)-baseline;
            psthHigh(ii,v,d,:) = raster2psth(rasterHigh,raster_params)-baseline;
            
        end
    end
    
end




figure;

subplot(3,2,1)

aveLow = mean(squeeze(psthLow(:,1,1,:)));
semLow = nanSEM(squeeze(psthLow(:,1,1,:)));
errorbar(ts,aveLow,semLow,'c'); hold on
aveLow = mean(squeeze(psthLow(:,2,1,:)));
semLow = nanSEM(squeeze(psthLow(:,2,1,:)));
errorbar(ts,aveLow,semLow,'k'); hold on
title('Low, PD')


subplot(3,2,2)

aveLow = mean(squeeze(psthLow(:,1,2,:)));
semLow = nanSEM(squeeze(psthLow(:,1,2,:)));
errorbar(ts,aveLow,semLow,'c'); hold on
aveLow = mean(squeeze(psthLow(:,2,2,:)));
semLow = nanSEM(squeeze(psthLow(:,2,2,:)));
errorbar(ts,aveLow,semLow,'k'); hold on
title('Low, Null')


subplot(3,2,3)

aveMid = mean(squeeze(psthMid(:,1,1,:)));
semMid = nanSEM(squeeze(psthMid(:,1,1,:)));
errorbar(ts,aveMid,semMid,'c'); hold on
aveMid = mean(squeeze(psthMid(:,2,1,:)));
semMid = nanSEM(squeeze(psthMid(:,2,1,:)));
errorbar(ts,aveMid,semMid,'k'); hold on   
title('Mid, PD')

subplot(3,2,4)

aveMid = mean(squeeze(psthMid(:,1,2,:)));
semMid = nanSEM(squeeze(psthMid(:,1,2,:)));
errorbar(ts,aveMid,semMid,'c'); hold on
aveMid = mean(squeeze(psthMid(:,2,2,:)));
semMid = nanSEM(squeeze(psthMid(:,2,2,:)));
errorbar(ts,aveMid,semMid,'k'); hold on   
title('Mid, Null')

subplot(3,2,5)
aveHigh = mean(squeeze(psthHigh(:,1,1,:)));
semHigh = nanSEM(squeeze(psthHigh(:,1,1,:)));
errorbar(ts,aveHigh,semHigh,'c'); hold on
aveHigh = mean(squeeze(psthHigh(:,2,1,:)));
semHigh = nanSEM(squeeze(psthHigh(:,2,1,:)));
errorbar(ts,aveHigh,semHigh,'k'); hold on
title('High, PD')

subplot(3,2,6)
aveHigh = mean(squeeze(psthHigh(:,1,2,:)));
semHigh = nanSEM(squeeze(psthHigh(:,1,2,:)));
errorbar(ts,aveHigh,semHigh,'c'); hold on
aveHigh = mean(squeeze(psthHigh(:,2,2,:)));
semHigh = nanSEM(squeeze(psthHigh(:,2,2,:)));
errorbar(ts,aveHigh,semHigh,'k'); hold on
title('High, Null')


figure;

aveTCLow = mean(TCLow);
aveTCMid = mean(TCMid);
aveTCHigh = mean(TCHigh);

semTCLow = nanSEM(TCLow);
semTCMid = nanSEM(TCMid);
semTCHigh = nanSEM(TCHigh);


errorbar(velocities,aveTCLow,semTCLow,'r'); hold on
errorbar(velocities,aveTCMid,semTCMid,'k');
errorbar(velocities,aveTCHigh,semTCHigh,'b');
