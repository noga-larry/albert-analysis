clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'BG msn'};
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;
req_params.num_trials = 70;

req_params.task = 'saccade_8_dir_75and25';
lines_choice = findLinesInDB (task_info, req_params);

req_params.task = 'pursuit_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);


raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 0;
bin_sz = 50;
 
ts = -raster_params.time_before:raster_params.time_after;

lines = findSameNeuronInTwoLinesLists(task_info,lines_choice,lines_single);

omegaR = nan(2,length(lines));
omegaD = nan(2,length(lines));
for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    both_cells{1} = importdata(cells{1}); both_cells{2} = importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;
    
    for j=1:length(both_cells)
        data = both_cells{j};
        
        boolFail = [data.trials.fail]; %| ~[data.trials.previous_completed];
        ind = find(~boolFail);
        [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
        [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
        
        raster = getRaster(data,ind,raster_params);
        response = downSampleToBins(raster',bin_sz)'*(1000/bin_sz);
        
        omegas = calOmegaSquare(response,{match_d,match_p},'partial',true);
        
        omegaD(j,ii) = omegas(2).value + omegas(4).value;
        omegaR(j,ii) = omegas(3).value + omegas(5).value;
    end
end


%%

N = length(req_params.cell_type);
figure; 

h = cellID<inf
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType) & h);
    
    subplot(2,N,i)
    scatter(omegaR(1,indType),omegaR(2,indType),'filled','k'); hold on
    p1 = signrank(omegaR(1,indType),omegaR(2,indType))
    [r,p2] = corr(omegaR(1,indType)',omegaR(2,indType)','type','Spearman');
    xlabel('saccade')
    ylabel('pursuit')
    equalAxis()
    refline(1,0)
    title(['reward ' req_params.cell_type{i}])
    subtitle(['signkrank: p = ' num2str(p1) ' | corr: r = ' num2str(r) ', p = ' num2str(p2)])
        
    subplot(2,N,N+i)
    scatter(omegaD(1,indType),omegaD(2,indType),'filled','k'); hold on
    p1 = signrank(omegaD(1,indType),omegaD(2,indType));
    [r,p2] = corr(omegaD(1,indType)',omegaD(2,indType)','type','Spearman');
    xlabel('saccade')
    ylabel('pursuit')
    equalAxis()
    refline(1,0)
    title(['Diretion ' req_params.cell_type{i}])
    subtitle(['signkrank: p = ' num2str(p1) ' | corr: r = ' num2str(r) ', p = ' num2str(p2)])
    
end
