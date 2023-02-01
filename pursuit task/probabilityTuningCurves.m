% Probability Tuning curves
clear; clc; close all
[task_info, supPath ,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("pursuit");

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

comparison_window = 0:800; % for TC

ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
angles = [0:45:180];
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);



for ii = 1:length(cells)

    data = importdata(cells{ii});

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

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

%%
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

directions = [-180:45:180];
f = figure; 

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
    ave_High = nanmean(squeeze(psth_High(ind,d,:)));
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
    sem_Low = nanSEM(squeeze(psth_Low(ind,d,:)));
    ave_High = nanmean(squeeze(psth_High(ind,d,:)));
    sem_High = nanSEM(squeeze(psth_High(ind,d,:)));
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
    ave_Low = mean(squeeze(psth_Low(ind,d,:)),'omitnan');
    sem_Low = nanSEM(squeeze(psth_Low(ind,d,:)));
    ave_High = mean(squeeze(psth_High(ind,d,:)),'omitnan');
    sem_High = nanSEM(squeeze(psth_High(ind,d,:)));
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

%% By type

figure

directions = [-180:45:180];

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    subplot(length(req_params.cell_type),1,i); hold on

    aveHigh = [nanmean(TC_High(indType,:)),nanmean(TC_High(indType,1))];
    semHigh = [nanSEM(TC_High(indType,:)),nanSEM(TC_High(indType,1))];
    aveLow = [nanmean(TC_Low(indType,:)),nanmean(TC_Low(indType,1))];
    semLow = [nanSEM(TC_Low(indType,:)), nanSEM(TC_Low(indType,1))];
    errorbar(directions,aveLow,semLow,'r'); hold on
    errorbar(directions,aveHigh,semHigh,'b'); hold on
    
    
    title([req_params.cell_type{i} ', n = ' num2str(length(indType))]);
    xlabel('direction')
    legend( '25','75')

end

figure
c=0;
for i = 1:length(req_params.cell_type)


    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    for d = 1:length(angles)

        c=c+1;
        subplot(length(req_params.cell_type),length(angles),c); hold on

        ave_Low = mean(squeeze(psth_Low(indType,d,:)),'omitnan');
        sem_Low = nanSEM(squeeze(psth_Low(indType,d,:)));
        ave_High = mean(squeeze(psth_High(indType,d,:)),'omitnan');
        sem_High = nanSEM(squeeze(psth_High(indType,d,:)));
        errorbar(ts,ave_Low,sem_Low,'r'); hold on
        errorbar(ts,ave_High,sem_High,'b'); hold on
        if d==1
            ylimits = get(gca,'YLim')
        end
        ylim([ylimits])
        legend( '25','75')
    title([req_params.cell_type{i} ','   num2str(angles(d)) ', n = ' num2str(length(indType))]);
        xlabel('Time from movement')
        legend( '25','75')
    end

end
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
