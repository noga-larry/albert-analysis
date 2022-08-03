% Probability Tuning curves
clear; clc; close all
[task_info, supPath ,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC cs';
req_params.task = 'saccade_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;
req_params.ID = 4000:6000;


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 15;

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
    boolFail = [data.trials.fail];
    
    [~,match_d] = getDirections(data);
    
    %match_d = permVec(match_d);
    
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
   
    for d = 1:length(angles)
        
        inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
        
        raster = getRaster(data,inx, raster_params);        
        
        psths(ii,d,:) = raster2psth(raster,raster_params) - baseline;
        
    end
    
    
end


save (task_DB_path,'task_info')

%%


directions = [-180:45:180];
figure;
subplot(2,1,1)
ave = [nanmean(TCpop),nanmean(TCpop(:,1))];
sem = [nanSEM(TCpop),nanSEM(TCpop(:,1))];

errorbar(directions,ave,sem); hold on
xlabel('direction')
ylimits = get(gca,'YLim');


for d = 1:length(angles)
    subplot(2,5,5+d)
    ave = nanmean(squeeze(psths(:,d,:)));
    sem = nanSEM(squeeze(psths(:,d,:)));
    
    
    errorbar(ts,ave,sem); hold on
    if d==1
        ylimits = get(gca,'YLim')
    end
    ylim([ylimits])
    
    title([num2str(angles(d))])
    xlabel('Time from movement')
end


