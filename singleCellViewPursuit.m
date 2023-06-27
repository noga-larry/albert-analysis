
%% Pursuit task
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');


PROBABILITIES = [25,75]; 
OUTCOMES =[0,1]; 

figure 
req_params = reqParamsEffectSize("both");
req_params.ID =  4055;
%req_params.cell_type = {'SNR'};

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

comparison_window = 100:800;
DIRECTIONS = 0:45:315;
PROBABILITIES = [25 75];
ts = -raster_params.time_before:raster_params.time_after;

f = figure;

for ii=1:length(cells)
    
    % cue
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    
    raster_params.align_to = 'cue';
    col = {'r','b'}; 
    
    
    ax = subplot(4,2,3);
    cla(ax)
    hold(ax,'on')
    xlabel('Time from cue')
        
    for p = 1:length(PROBABILITIES)
        
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        raster = getRaster(data,ind,raster_params);
        [psth,sem] = raster2psth(raster,raster_params);    
        
        subplot(4,4,p)
        
        plotRaster(raster,raster_params,col{p})
        xlabel('Time from cue')
        title([num2str(data.info.cell_ID) ' - ' data.info.cell_type ', ' data.info.task], 'Interpreter', 'none');
        
        errorbar(ax,ts,psth,sem,col{p})
        
    end
    
    
     
    % reward
    raster_params.align_to = 'reward';
    ax1 = subplot(4,4,13); hold on
    ax2 = subplot(4,4,14); hold on
    
    marker = {'--','-'}; 
    
    for i = 1:length(OUTCOMES)
        inx = find(match_o==OUTCOMES(i) & ~boolFail); 
        raster = getRaster(data,inx,raster_params);
        psth = raster2psth(raster,raster_params);
        plot(ax1,ts,psth,col{i})
        xlabel('Time from reward')
        
        subplot(8,4,17+4*OUTCOMES(i))
        plotRaster(raster,raster_params,col{i})
        xlabel('Time from reward')
        
        inx = find (~boolFail);
        [~,p] = sort(match_p(inx))
        inx = inx(p);
        raster = getRaster(data,inx,raster_params);
        
        subplot(8,4,18+4*OUTCOMES(i))
        plotRaster(raster,raster_params,col{i})
        xlabel('Time from reward')
        
        for p = 1:length(PROBABILITIES)
            inx = find (match_p == PROBABILITIES(p) & (~boolFail) & match_o==OUTCOMES(i));
            raster = getRaster(data,inx,raster_params);
            psth = raster2psth(raster,raster_params);
            plot(ax2,ts,psth,[col{p} marker{i}] )
        end
        legend('R','NR')
    end
    
    

    
    % direction
    raster_params.align_to = 'targetMovementOnset';

    inx = find (~boolFail);
    [~,p] = sort(match_d(inx));
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

