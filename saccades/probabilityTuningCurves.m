% Probability Tuning curves
clear all

supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;

comparison_window = 100:500; % for TC

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
    [~,match_p] = getProbabilities (data);
    
    [TC,~,h(ii)] = getTC(data, directions,1:length(data.trials), comparison_window);
    [PD,indPD] = centerOfMass (TC, directions);
    TCpop(ii,:) = circshift(TC,5-PD);
    
    data.info.PD = PD;
    data.info.directionally_tuned = h(ii);
    save (cells{ii},'data');
    
    task_info(lines(ii)).directionally_tuned = h(ii);
    task_info(lines(ii)).PD = PD;
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

figure;
ind = find(h);
subplot(2,1,1)
col = varycolor(5)
plot(mean(TC_High(ind,5),2),mean(TC_Low(ind,5),2),'*','Color',col(1,:)); hold on
for d=1:3
plot(mean(TC_High(ind,5+d),2),mean(TC_Low(ind,5+d),2),'*','Color',col(1+d,:)); hold on
plot(mean(TC_High(ind,5-d),2),mean(TC_Low(ind,5-d),2),'*','Color',col(1+d,:)); hold on
end
xLimits = get(gca,'XLim') 
yLimits = get(gca,'XLim') 
limits(1) = min([xLimits(1) xLimits(1)] )
limits(2) = max([xLimits(2) xLimits(2)] )
ylim(limits)
xlim(limits)
refline(1,0)
title('Tuned')
plot(mean(TC_High(ind,1),2),mean(TC_Low(ind,1),2),'*','Color',col(5,:)); hold on



ind = find(~h);
subplot(2,1,2)
col = varycolor(5)
plot(mean(TC_High(ind,5),2),mean(TC_Low(ind,5),2),'*','Color',col(1,:)); hold on
for d=1:3
plot(mean(TC_High(ind,5+d),2),mean(TC_Low(ind,5+d),2),'*','Color',col(1+d,:)); hold on
plot(mean(TC_High(ind,5-d),2),mean(TC_Low(ind,5-d),2),'*','Color',col(1+d,:)); hold on
end
plot(mean(TC_High(ind,1),2),mean(TC_Low(ind,1),2),'*','Color',col(5,:)); hold on


xLimits = get(gca,'XLim') 
yLimits = get(gca,'XLim') 
limits(1) = min([xLimits(1) xLimits(1)] )
limits(2) = max([xLimits(2) xLimits(2)] )
ylim(limits)
xlim(limits)
refline(1,0)
title('Not Tuned')



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
trueMeanSquares = mean((aveHigh_sig-aveLow_sig).^2);
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

