clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';

req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = 1;
req_params.num_trials = 50;
req_params.remove_repeats = false;
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';


req_params.cell_type = 'BG msn';
lines1 = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC ss|CRB';
lines2 = findLinesInDB (task_info, req_params);
req_params.remove_question_marks = 1;

pairs = findPairs(task_info,lines1,lines2,req_params.num_trials);

for ii = 1:length(pairs)
    
    cells = findPathsToCells (supPath,task_info,[pairs(ii).cell1,pairs(ii).cell2]);
    data1 = importdata(cells{1});
    data2 = importdata(cells{2});
    [data1,data2] = reduceToSharedTrials(data1,data2);
    
    assert(length(data1.trials)>=req_params.num_trials)

    effects(1,ii) = effectSizeInEpoch(data1,EPOCH);
    effects(2,ii) = effectSizeInEpoch(data2,EPOCH);

end

%%

f = fields(effects);
N= length(f)

figure;

for ii = 1:length(f)
    subplot(N,1,ii)
    scatter([effects(1,:).(f{ii})],[effects(2,:).(f{ii})])
    p = signrank([effects(1,:).(f{ii})],[effects(2,:).(f{ii})]);
    refline(1,0)
    xlabel('BG')
    ylabel('Cerrebellum')
    title([ f{ii} ', p = ' num2str(p)  ' n = ' num2str(length(pairs)) ])
end

sgtitle(EPOCH)
