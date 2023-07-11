clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

DIRECTIONS = 0:45:315;

req_params = reqParamsEffectSize("pursuit");
lines_pursuit = findLinesInDB (task_info, req_params);

req_params = reqParamsEffectSize("saccade");
lines_saccade = findLinesInDB (task_info, req_params);

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

comparison_window = 0:800; % for TC


lines = findSameNeuronInTwoLinesLists(task_info,lines_pursuit,lines_saccade);

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    data_pur = importdata(cells{1}); data_sacc= importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;


    [TC_sacc,~,h_sacc(ii)] = getTC(data_sacc, DIRECTIONS,1:length(data_sacc.trials), comparison_window);
    [~,indPD,PD_sacc(ii)] = centerOfMass (TC_sacc, DIRECTIONS);
    TC_pop_sacc(ii,:) = circshift(TC_sacc,5-indPD) - mean(TC_sacc);

    [TC_pur,~,h_pur(ii),] = getTC(data_pur, DIRECTIONS,1:length(data_pur.trials), comparison_window);
    [~,~,PD_pur(ii)] = centerOfMass (TC_pur, DIRECTIONS);
    TC_pop_pur(ii,:) = circshift(TC_pur,5-indPD) - mean(TC_pur);

end


%%

N = length(req_params.cell_type);
figure;
DIRECTIONS = [-180:45:180];
inx = find(h_sacc | h_pur); 

for i = 1:N
    
    indType = intersect(inx,find(strcmp(req_params.cell_type{i}, cellType)));

    subplot(N,1,i)
    
    ave_pur = [nanmean(TC_pop_pur(indType,:)),nanmean(TC_pop_pur(indType,1))];
    sem_pur = [nanSEM(TC_pop_pur(indType,:)),nanSEM(TC_pop_pur(indType,1))];
    ave_sacc = [nanmean(TC_pop_sacc(indType,:)),nanmean(TC_pop_sacc(indType,1))];
    sem_sacc = [nanSEM(TC_pop_sacc(indType,:)), nanSEM(TC_pop_sacc(indType,1))];
    
    errorbar(DIRECTIONS,ave_pur,sem_pur,'r'); hold on
    errorbar(DIRECTIONS,ave_sacc,sem_sacc,'b'); hold on
    
    legend('pursuit','saccade')

    xlabel('angle from saccade PD')

    title([req_params.cell_type{i} ', n = ' num2str(length(indType))...
        '/' num2str(sum(strcmp(req_params.cell_type{i}, cellType)))]);


end

%% PD correlation

figure; hold on
inx = find(h_sacc | h_pur);

for i = 1:length(req_params.cell_type)
    
    indType = intersect(inx,find(strcmp(req_params.cell_type{i}, cellType)));
    
    scatter(PD_pur(indType),PD_sacc(indType))
    [rho, pval] = circ_corrcc(PD_pur(indType),PD_sacc(indType));
    disp([req_params.cell_type{i} ': r = ' num2str(rho) ' , p = ' num2str(pval)])
end

xlabel('Pursuit');ylabel('Saccade')
legend(req_params.cell_type)
%%

figure; hold on
inx = find(h_sacc | h_pur);

for i = 1:length(req_params.cell_type)
    
    indType = intersect(inx,find(strcmp(req_params.cell_type{i}, cellType)));
    disp(['n = ' num2str(length(indType)) '/' ...
        num2str(sum(strcmp(req_params.cell_type{i}, cellType)))])
    plotHistForFC(mod(abs(PD_pur(indType)-PD_sacc(indType)),180),0:20:180);
end
xlabel('Pursuit-Sacc');ylabel('Frac')
legend(req_params.cell_type)
