clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    effects1(1,ii) = effectSizeInEpoch(data,'cue');
    effects2(1,ii) = effectSizeInEpoch(data,'targetMovementOnset');
    
    
end

%%
figure;
N = length(req_params.cell_type);

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,2,i)
    scatter([effects1(indType).reward],[effects2(indType).direction],'filled');
    [r,p] = corr([effects1(indType).reward]',[effects2(indType).direction]');
    title(['time, r = ' num2str(r) ', p = ' num2str(p)])
    subtitle(req_params.cell_type{i})
    xlabel('cue')
    ylabel('motion')    
    equalAxis()
    refline(1,0)


end

%%

figure
N = length(req_params.cell_type);


for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,N,i)
    scatter([effects1(indType).reward],[effects2(indType).direction],'filled');
    p = signrank([effects1(indType).reward],[effects2(indType).direction]);
    title(['time, p = ' num2str(p)])
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
