clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.num_trials = 120;

epoch = 'cue';
 
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
   
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    
    match_d = match_d(1,:);
    match_p = (match_p(1,:)/25)*length(PROBABILITIES)+(match_p(2,:)/25);
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BIN_SIZE)'*(1000/BIN_SIZE);

    omegas = calOmegaSquare(response,{match_d,match_p}); 
    
    omegaT(ii) = omegas(1).value;
    omegaD(ii) = omegas(2).value + omegas(4).value;
    omegaR(ii) = omegas(3).value + omegas(5).value;
    
    overAllExplained(ii) = omegas(6).value;
    
    
end


%%

N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,N,i)
    scatter(omegaT(indType),omegaR(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaR(indType));
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
        
    subplot(3,N,i+N)
    scatter(omegaT(indType),omegaD(indType),'filled','k'); hold on
    p = signrank(omegaT(indType),omegaD(indType));
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
    subplot(3,N,i+2*N)
    scatter(omegaR(indType),omegaD(indType),'filled','k'); hold on
    p = signrank(omegaR(indType),omegaD(indType));
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
end