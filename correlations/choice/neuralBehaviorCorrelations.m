clear all

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');

NUM_COND = 20;
req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 100;
req_params.remove_question_marks =0;
req_params.remove_repeats = 0;


raster_params.time_before = 700;
raster_params.time_after = 1000;
raster_params.smoothing_margins = 0;
raster_params.align_to = 'targetMovementOnset';

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

displayTime = behavior_params.time_after+behavior_params.time_before+1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    boolFail = [data.trials.fail];        
    [~,match_d] = getDirections(data);        
    ind = find(~boolFail & match_d(1,:)==90);
    [~,~,velH,velV] =...
        meanVelocitiesRotated(data,behavior_params,ind,...
        'smoothIndividualTrials',true); 
    
    angles = atand(nanmean(velV(:,end-50:end),2) ./...
        nanmean(velH(:,end-50:end),2));
    
   
    [~, ~, direction] = fitTimingDirectionAndGain(data,ind);
    
    choice = [data.trials(ind).choice];
    
    raster = getRaster(data,ind,raster_params);
    firing_rate = mean(raster,1)'*1000;
    
    bias_correlation(ii) = ...
        corr(firing_rate,direction','Rows','Pairwis');
    
    effect_sz = mes(firing_rate(choice==0),...
        firing_rate(choice==1),'hedgesg');
    choice_hedgesg(ii) = effect_sz.hedgesg;

end

%%

figure;
subplot(2,1,1)
plotHistForFC(bias_correlation,20)
xlabel('Correlation of FR with direction')
ylabel('Fraction')

subplot(2,1,2)
plotHistForFC(choice_hedgesg,20)
xlabel('Hedges''s g (choice)')
ylabel('Fraction')

sgtitle([req_params.cell_type ' ,' ...
    num2str(raster_params.time_before) ' to ' ...
    num2str(raster_params.time_after)])