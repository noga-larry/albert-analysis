%clear all


[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

angles = [0,90];
probabilities = [0:25:100];
col = varycolor(10);

req_params.grade = 7;
%req_params.cell_type = 'BG msn';
req_params.task = 'choice';
req_params.ID = 4357;
req_params.num_trials = 100;
req_params.remove_question_marks =0;
req_params.remove_repeats = 0;

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
raster_params.align_to = 'reward';

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before:raster_params.time_after;


for ii=1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    for d = 1:length(angles)
        
        boolDir = match_d(1,:)== angles(d);
        ind = find(~boolFail & boolDir);
        
        [~,sort_inx] = sortrows(match_p(:,ind)');
        raster = getRaster(data,ind(sort_inx),raster_params);
        
        subplot(2,2,d)
        plotRaster(raster,raster_params,'k')
        title(num2str(angles(d)))
        
        ax{d} = subplot(2,2,2+d); hold on
        
        prob_counter = 0;
        for j = 1:length(probabilities)
            for  k = j+1:length(probabilities)
                
                prob_counter = prob_counter +1;
                boolProb = (match_p(1,:) == probabilities(k) & ...
                    match_p(2,:) == probabilities(j));
                ind = find (boolProb & (~boolFail) & boolDir);
                raster = getRaster(data,ind,raster_params);
                psth = raster2psth(raster,raster_params);
                plot(ts,psth,'Color',col(prob_counter,:))
            end
        end
        subplot(2,2,2+d); hold off
    end
    sgtitle([num2str(data.info.cell_ID) ' - '...
        data.info.cell_type ])
    
    pause
    
    cla(ax{1});cla(ax{2})
end