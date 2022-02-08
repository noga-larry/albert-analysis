clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 70;
req_params.remove_question_marks = 1;

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;

BINE_SIZE = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
   
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);

    raster_params.align_to = 'reward';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BINE_SIZE)'*(1000/BINE_SIZE);
    
    omegas = calOmegaSquare(response,{match_o,match_d},'partial',true);
    
    omegaT(1,ii) = omegas(1).value;
    omegaO(1,ii) = omegas(2).value + omegas(4).value;
    
    raster_params.align_to = 'cue';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BINE_SIZE)'*(1000/BINE_SIZE);
    
    omegas = calOmegaSquare(response,{match_p},'partial',true);
    
    omegaT(2,ii) = omegas(1).value;
    omegaO(2,ii) = omegas(2).value + omegas(3).value;
    
end

%%
figure;

N = length(req_params.cell_type);
figure;


for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(2,N,i)
    scatter(omegaT(1,indType),omegaT(2,indType),'filled');
    [r,p] = corr(omegaT(1,indType)',omegaT(2,indType)','type','Spearman','Rows','Pairwise');
    title(['time , r = ' num2str(r) ', p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('movement')
    ylabel('cue')    
    equalAxis()
    refline(1,0)
    
    subplot(2,N,N+i)
    scatter(omegaO(1,indType),omegaO(2,indType),'filled');
    [r,p] = corr(omegaO(1,indType)',omegaO(2,indType)','type','Spearman','Rows','Pairwise');
    title(['outcome , r = ' num2str(r) ', p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('movement')
    ylabel('cue')
    equalAxis()
    refline(1,0)
end