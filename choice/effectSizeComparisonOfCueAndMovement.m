clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaRCue = nan(1,length(cells));
omegaRMovement = nan(1,length(cells));
omegaDMovement = nan(1,length(cells));

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
   
   
    boolFail = [data.trials.fail] | ~[data.trials.choice]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    match_d = match_d(1,:);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    
    
    % cue
    raster_params.align_to = 'cue';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);

    omegas = calOmegaSquare(response,{match_d,match_p}); 
    
    omegaRCue(ii) = omegas(3).value + omegas(5).value;
    
    % movement
    
    raster_params.align_to = 'targetMovementOnset';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);

    omegas = calOmegaSquare(response,{match_d,match_p}); 
    
    omegaRMovement(ii) = omegas(3).value + omegas(5).value;
    omegaDMovement(ii) = omegas(2).value + omegas(4).value;
end


%%
N = length(req_params.cell_type);
figure;

bool = cellID<5000
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType) & bool);
    
    subplot(2,N,i)
    scatter(omegaRCue(indType),omegaRMovement(indType),'filled','k'); hold on
    [r,p] = corr(omegaRCue(indType)',omegaRMovement(indType)');
    xlabel('Cue reward')
    ylabel('Movement Reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['r = ' num2str(r) ', p = ' num2str(p)])
    
    subplot(2,N,i+N)
    scatter(omegaRCue(indType),omegaDMovement(indType),'filled','k'); hold on
    [r,p] = corr(omegaRCue(indType)',omegaDMovement(indType)');
    xlabel('Cue reward')
    ylabel('Movement direction')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['r = ' num2str(r) ', p = ' num2str(p)])
    
end