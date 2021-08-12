clear

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');
PLOT_INDIVIDUAL = 0;
ANGLES = [0,90];
NUM_COND = 20;
req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 150;
req_params.remove_question_marks = 1;
req_params.remove_repeats = 1;

raster_params.time_before = 300;
raster_params.time_after = 600;
raster_params.smoothing_margins = 0;
raster_params.align_to = 'targetMovementOnset';

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

display_time = behavior_params.time_after+behavior_params.time_before+1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

probabilities  = [0:25:100];
velH = nan(display_time);
velV = nan(display_time);

col = varycolor(NUM_COND);


for ii = 1:length(cells)
    
    condCounter = 0;
    data = importdata(cells{ii});
    
    % PD = data.info.PD;
    
    [probabilities,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    boolProb = (match_p(1,:) == 100 & ...
        match_p(2,:) == 0);
    
    for d = 1:length(ANGLES)
        boolDir = match_d(1,:) == ANGLES(d);
        ind = find(boolProb & ~boolFail & boolDir);
        raster = getRaster(data,ind,raster_params);
        edgePobabilitiesSpks{d} = mean(mean(raster))*1000;
    end
    
    PD = ANGLES(heaviside(mean(edgePobabilitiesSpks{1})...
        -mean(edgePobabilitiesSpks{2}))+1);
    
    if PLOT_INDIVIDUAL
        ax1 = subplot(2,1,1); hold on
        ax2 = subplot(2,1,2); hold on
    end
    
    for d = 1:length(ANGLES)
        
        boolDir = match_d(1,:) == ANGLES(d);
        
        for j = 1:length(probabilities)
            
            
            for  k = j+1:length(probabilities)
                
                if (probabilities(k)==100) & (probabilities(j)==0)
                    continue
                end
                condCounter = condCounter+1;
                boolProb = (match_p(1,:) == probabilities(k) & ...
                    match_p(2,:) == probabilities(j));
                ind = find(boolProb & ~boolFail & boolDir);
                
                if PD == 0
                    [velH,velV] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                else
                    % Flip axis so that the horizontal is the PD
                    [velV,velH] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                end
                
                movement_angle(condCounter) = atand(nanmean(velV(end-50:end)) ./...
                    nanmean(velH(end-50:end)));
                bias(condCounter) = movement_angle(condCounter);
                
                raster = getRaster(data,ind,raster_params);
                
                spks(condCounter) = mean(mean(raster))*1000;
                
                if PLOT_INDIVIDUAL
                    
                    plot(ax1,spks(condCounter),bias(condCounter)...
                        ,'*','Color',col(condCounter,:));
                    plot(ax2,velH,velV...
                        ,'Color',col(condCounter,:));
                    equalAxis();
                end
            end
        end
    end
    correlation(ii) = corr(spks',bias');
    
    if PLOT_INDIVIDUAL
        sgtitle([num2str(correlation(ii)) ', PD = ' ...
            num2str(PD)]);
        equalAxis();
        pause
        cla(ax1);cla(ax2);
    end
end
%% Averaging over all cells

clear

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');
ANGLES = [0,90];
NUM_COND = 10;
req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 150;
req_params.remove_question_marks = 1;
req_params.remove_repeats = 1;

raster_params.time_before = -600;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
raster_params.align_to = 'cue';

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

display_time = behavior_params.time_after+behavior_params.time_before+1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

probabilities  = [0:25:100];
velH = nan(length(cells),length(ANGLES),NUM_COND,display_time);
velV = nan(length(cells),length(ANGLES),NUM_COND,display_time);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    PD = data.info.PD;
    
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    for d = 1:length(ANGLES)
        
        condCounter = 0;
        
        boolDir = match_d(1,:) == mod(PD+ANGLES(d),180);
        
        for j = 1:length(probabilities)
            
            for  k = j+1:length(probabilities)
                
                condCounter = condCounter+1;
                boolProb = (match_p(1,:) == probabilities(k) & ...
                    match_p(2,:) == probabilities(j));
                ind = find(boolProb & ~boolFail & boolDir);
                
                if PD == 0
                    [velH(ii,d,condCounter,:),velV(ii,d,condCounter,:)] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                else
                    % Flip axis so that the horizontal is the PD
                    [velV(ii,d,condCounter,:),velH(ii,d,condCounter,:)] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                end
                
                raster = getRaster(data,ind,raster_params);
                spks(ii,d,condCounter) = mean(mean(raster))*1000;
                
                fracCorrect(ii,d,condCounter) = mean([data.trials(ind).choice]);
            end
            
        end
    end
    
end


aveVelV = squeeze(nanmean(velV)); aveVelH = squeeze(nanmean(velH));
aveSpks = squeeze(mean(spks));
aveFracCorrect = squeeze(mean(fracCorrect));
for d = 1:length(ANGLES)
    ax(1,d) = subplot(2,2,d);
    movement_angle(d,:)= atand(nanmean(aveVelV(d,:,end-50:end),3) ./...
        nanmean(aveVelH(d,:,end-50:end),3));
    scatter(aveSpks(d,:),movement_angle(d,:)')
    [r(1,d),p(1,d)] = corr(aveSpks(d,:)',movement_angle(d,:)');
    xlabel('Average fr')
    ylabel('Angle of average')
    
    ax(2,d) = subplot(2,2,2+d);
    scatter(aveSpks(d,:),aveFracCorrect(d,:)')
    [r(2,d),p(2,d)] = corr(aveSpks(d,:)',aveFracCorrect(d,:)');
    xlabel('Average fr')
    ylabel('fraction correct')
end
title(ax(1,1),['PD,r = ' num2str(r(1,1)), ' ,p = ' num2str(p(1,1))])
title(ax(1,2),['Null,r = ' num2str(r(1,2)), ' ,p = ' num2str(p(1,2))])

title(ax(2,1),['PD,r = ' num2str(r(2,1)), ' ,p = ' num2str(p(2,1))])
title(ax(2,2),['Null,r = ' num2str(r(2,2)), ' ,p = ' num2str(p(2,2))])

% ylim(ax(1,1),[0 45])
% ylim(ax(1,2),[45 90])

sgtitle(['Time: ' num2str(-raster_params.time_before)...
    ' to ' num2str(raster_params.time_after)])
    

%%

figure;
plotHistForFC(correlation,15)
xlabel('Correlation with behavior angle relative to 45')
ylabel('Frac')
p = signrank(correlation);
title(['Time: ' num2str(raster_params.time_before)...
    ' to ' num2str(raster_params.time_after) ...
    ', signrank: p=' num2str(p)...
    ', n=' num2str(length(cells))])
%%

figure;
plotHistForFC(correlation,15)
xlabel('Correlation with behavior angle relative to 45')
ylabel('Frac')
p = signrank(correlation);
title(['Time: ' num2str(raster_params.time_before)...
    ' to ' num2str(raster_params.time_after) ...
    ', signrank: p=' num2str(p)...
    ', n=' num2str(length(cells))])

%% Running window
clear

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');

WINDOW_SIZE = 300;
ANGLES = [0,90];
NUM_COND = 20;
req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 150;
req_params.remove_question_marks = 1;
req_params.remove_repeats = 1;

raster_params.time_before = 500;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.align_to = 'targetMovementOnset';

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

display_time = behavior_params.time_after+behavior_params.time_before+1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

probabilities  = [0:25:100];
velH = nan(display_time);
velV = nan(display_time);


for ii = 1:length(cells)
    
    condCounter = 0;
    data = importdata(cells{ii});
    
    % PD = data.info.PD;
    
    [probabilities,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    boolProb = (match_p(1,:) == 100 & ...
        match_p(2,:) == 0);
    
    for d = 1:length(ANGLES)
        boolDir = match_d(1,:) == ANGLES(d);
        ind = find(boolProb & ~boolFail & boolDir);
        raster = getRaster(data,ind,raster_params);
        edgePobabilitiesSpks{d} = mean(mean(raster))*1000;
    end
    
    PD = ANGLES(heaviside(mean(edgePobabilitiesSpks{1})...
        -mean(edgePobabilitiesSpks{2}))+1);
    
    for d = 1:length(ANGLES)
        
        boolDir = match_d(1,:) == ANGLES(d);
        
        for j = 1:length(probabilities)
            
            for  k = j+1:length(probabilities)
                
                if (probabilities(k)==100) & (probabilities(j)==0)
                    continue
                end
                condCounter = condCounter+1;
                boolProb = (match_p(1,:) == probabilities(k) & ...
                    match_p(2,:) == probabilities(j));
                ind = find(boolProb & ~boolFail & boolDir);
                
                indicesCell{condCounter} = ind;
                
                if PD == 0
                    [velH,velV] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                else
                    % Flip axis so that the horizontal is the PD
                    [velV,velH] =...
                        meanVelocitiesRotated(data,behavior_params,ind);
                end
                
                movement_angle(condCounter) = atand(nanmean(velV(end-50:end)) ./...
                    nanmean(velH(end-50:end)));
                bias(condCounter) = movement_angle(condCounter);
            end
        end
    end
    
    raster = getRaster(data,1:length(data.trials),raster_params);
    
    func = @(x) correlateFiringAndBias(x,bias,indicesCell);
    correlations(ii,:) = runningWindowFunction(raster,func,WINDOW_SIZE);
    
end

%%
figure;
plot(nanmean(correlations))
%%
function correlation = correlateFiringAndBias(raster,bias,indices)

for ii=1:length(indices)
    spks(ii) = mean(mean(raster(:,indices{ii})))*1000;
end
correlation = corr(spks',bias');
end
