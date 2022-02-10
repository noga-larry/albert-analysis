clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Albert behavior before recording');

PROBABILITIES = [0:25:100];

req_params.task = 'pursuit_8_dir_75and25';
req_params.num_trials = 50;
req_params.remove_repeats = false;

behavior_params.time_after = 700;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms


f = @(x) length(x)==5 | length(x)==4;
h1 = cellfun(f,{task_info.probabilities});
f = @(x) length(x)==8 | length(x)==4;
h2 = cellfun(f,{task_info.directions});

lines = intersect(findLinesInDB (task_info, req_params),find(h1 & h2));
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    for p = 1: length(PROBABILITIES)
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        vel(ii,p,:) = meanVelocitiesRotated(data,behavior_params,ind);
    end
    
end

%%
figure
ave = squeeze(nanmean(vel))';
sem = squeeze(nanSEM(vel))';
errorbar(ave,sem)

legend('0','25','50','75','100')


%%

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Albert behavior before recording');

PROBABILITIES = [0:25:100];

req_params.task = 'saccade_8_dir_75and25';
req_params.num_trials = 50;
req_params.remove_repeats = false;


f = @(x) length(x)==5 | length(x)==4;
h1 = cellfun(f,{task_info.probabilities});
f = @(x) length(x)==8 | length(x)==4;
h2 = cellfun(f,{task_info.directions});

lines = intersect(findLinesInDB (task_info, req_params),find(h1 & h2));
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    for p = 1: length(PROBABILITIES)
        ind = find (match_p == PROBABILITIES(p) & (~boolFail));
        RT(ii,p) = median(saccadeRTs(data,ind));
    end
    
end

%%
figure
ave = squeeze(nanmean(RT))';
sem = squeeze(nanSEM(RT))';
errorbar(PROBABILITIES,ave,sem)
xlabel('Probability')
ylabel('RT (ms)')
