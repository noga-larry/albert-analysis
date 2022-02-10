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
    cellID(ii) = data.info.cell_ID;
   
    boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
    ind = find(~boolFail);
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
    [match_o] = getOutcome (data,ind,'omitNonIndexed',true);
    
    raster_params.align_to = 'targetMovementOnset';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BINE_SIZE)'*(1000/BINE_SIZE);
    
    omegas = calOmegaSquare(response,{match_p,match_d},'partial',true);
    
    omegaT(1,ii) = omegas(1).value;
    omegaR(1,ii) = omegas(2).value + omegas(4).value;
    omegaD(1,ii) = omegas(3).value + omegas(5).value;
    
    raster_params.align_to = 'reward';
    raster = getRaster(data,find(~boolFail),raster_params);
    response = downSampleToBins(raster',BINE_SIZE)'*(1000/BINE_SIZE);
    
    omegas = calOmegaSquare(response,{match_o,match_d},'partial',true);
    
    omegaT(2,ii) = omegas(1).value;
    omegaR(2,ii) = omegas(2).value + omegas(4).value;
    omegaD(2,ii) = omegas(3).value + omegas(5).value;
end

%%
figure;

N = length(req_params.cell_type);


for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,N,i)
    scatter(omegaT(1,indType),omegaT(2,indType),'filled');
    p = signrank(omegaT(1,indType),omegaT(2,indType));
    title(['time, p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('movement')
    ylabel('outcome')    
    equalAxis()
    refline(1,0)
    
    subplot(3,N,N+i)
    scatter(omegaR(1,indType),omegaR(2,indType),'filled');
    p = signrank(omegaR(1,indType),omegaR(2,indType));
    title(['reward, p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('movement')
    ylabel('outcome')
    equalAxis()
    refline(1,0)
    
    subplot(3,N,2*N+i)
    scatter(omegaD(1,indType),omegaD(2,indType),'filled');
    p = signrank(omegaD(1,indType),omegaD(2,indType));
    title(['direction ,p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('movement')
    ylabel('outcome')
    equalAxis()
    refline(1,0)

end


%%

figure

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(2,ceil(N/2),i)
    x = omegaD(1,indType); y = omegaR(2,indType);
    x = randPermute(x);y = randPermute(y);
    scatter(x,y,'filled');
    subtitle(req_params.cell_type{i})
    xlabel('movement: direction')
    ylabel('outcome: reward')    
    equalAxis()
    refline(1,0)    
    

end
