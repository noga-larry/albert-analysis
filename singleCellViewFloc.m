
%% Pursuit task
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Floc');


figure
req_params.grade = 7;
req_params.cell_type = {'PC cs'};


req_params.num_trials = 50;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.task = 'rwd_direction_tuning';
req_params.ID = 3390:4000;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

comparison_window = 100:300;
DIRECTIONS = 0:45:315;
ts = -raster_params.time_before:raster_params.time_after;

f = figure;

for ii=1:length(cells)
    
    % cue
    
    data = importdata(cells{ii});
    [cue_types,match_p] = getRewardSize (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    raster_params.align_to = 'cue';
    col = {'b','r'};
    
    
    ax1 = subplot(4,2,3);
    ax2 = subplot(4,2,7);
    cla(ax1); cla(ax2)
    hold(ax1,'on');hold(ax2,'on')
    xlabel('Time from cue')
    
    for p = 1:length(cue_types)
        
        ind = find (strcmp(match_p,cue_types(p)) & (~boolFail));
        raster = getRaster(data,ind,raster_params);
        [psth,sem] = raster2psth(raster,raster_params);
        
        % cue
        subplot(4,4,p)
        
        plotRaster(raster,raster_params,col{p})
        xlabel('Time from cue')
        title([num2str(data.info.cell_ID) ' - ' data.info.cell_type ', ' data.info.task], 'Interpreter', 'none');
        
        errorbar(ax1,ts,psth,sem,col{p})
        
        
        % reward
        raster_params.align_to = 'reward';
        
        subplot(4,4,8+p)
        raster = getRaster(data,ind,raster_params);
        
        plotRaster(raster,raster_params,col{p})
        xlabel('Time from cue')
        
        psth = raster2psth(raster,raster_params);
        plot(ax2,ts,psth,col{p})
        xlabel('Time from reward')
    
        
    end
    
    legend(cue_types)
    
    % direction
    raster_params.align_to = 'targetMovementOnset';
    
    
    
    inx = find (~boolFail);
    [~,p] = sort(match_d(inx))
    inx = inx(p);
    
    raster = getRaster(data,inx, raster_params);
    subplot(2,2,2)
    plotRaster(raster,raster_params,match_d(inx))
    xlabel('Time from movement')
    
    subplot(2,2,4)
    colors = varycolor(length(DIRECTIONS));
    
    for d = 1:length(DIRECTIONS)
        
        inx = find (match_d == DIRECTIONS(d)& ~boolFail);
        
        raster = getRaster(data,inx, raster_params);
        psthHigh = raster2psth(raster,raster_params);
        plot(ts,psthHigh,'Color',colors(d,:)); hold on
        
    end
    hold off
    legend('0','45','90','135','180','225','270','315')
    pause
    arrayfun(@cla,f.Children)
end

