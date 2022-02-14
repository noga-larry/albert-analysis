% Probability Tuning curves
clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'SNR';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.align_to = 'targetMovementOnset';
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

cell_ID = [];

for ii = 1:length(cells)
    data = importdata(cells{ii});
    cell_ID  = [cell_ID,data.info.cell_ID];
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
   
   if ~strcmp(req_params.cell_type,'PC cs')
       baseline = mean(TCpop(ii,:));
   else
       
       baseline =0;
   end
   TC_High(ii,:) =  circshift(getTC(data, directions,inxHigh, comparison_window),5-indPD)-baseline;
   TC_Low(ii,:)= circshift(getTC(data, directions, inxLow, comparison_window),5-indPD)-baseline;

    
    for d = 1:length(angles)
       
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        raster_High = getRaster(data,intersect(inx,inxHigh), raster_params);
        raster_Low = getRaster(data, intersect(inx,inxLow), raster_params);
        
        psth_High(ii,d,:) = raster2psth(raster_High,raster_params)-baseline;
        psth_Low(ii,d,:) = raster2psth(raster_Low,raster_params)-baseline;

    end
    
    
end




figure;
directions = [-180:45:180];
figure;
ind = find(~h);
subplot(3,1,1)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanstd(TC_High(ind,:)),nanstd(TC_High(ind,1))]/sqrt(length(ind));
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanstd(TC_Low(ind,:)), nanstd(TC_Low(ind,1))]/sqrt(length(ind));
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Untuned, n = ' num2str(length(ind))]);

ind = find(h);
subplot(3,1,2)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanstd(TC_High(ind,:)),nanstd(TC_High(ind,1))]/sqrt(length(ind));
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanstd(TC_Low(ind,:)), nanstd(TC_Low(ind,1))]/sqrt(length(ind));
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['Significantly tuned, n = ' num2str(sum(h))]);
xlabel('direction')
legend( '25','75')

ind = 1:length(cells);
subplot(3,1,3)
aveHigh = [nanmean(TC_High(ind,:)),nanmean(TC_High(ind,1))];
semHigh = [nanstd(TC_High(ind,:)),nanstd(TC_High(ind,1))]/sqrt(length(ind));
aveLow = [nanmean(TC_Low(ind,:)),nanmean(TC_Low(ind,1))];
semLow = [nanstd(TC_Low(ind,:)), nanstd(TC_Low(ind,1))]/sqrt(length(ind));
errorbar(directions,aveLow,semLow,'r'); hold on
errorbar(directions,aveHigh,semHigh,'b'); hold on
title(['All, n = ' num2str(length(cells))]);
xlabel('direction')
legend( '25','75')


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
    legend('25','75')
end
title(['Not Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')


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
    legend('25','75')
end
title([' Tuned, n = ' num2str(length(ind))]);
xlabel('Time from movement')

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

