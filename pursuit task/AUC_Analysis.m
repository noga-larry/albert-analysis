%%
clear

REPEATS = 10000;
T = 100;

L = 2;


for ii = 1:REPEATS

    response = randn(1,T);
    group = mod(1:T,L);

    if mean(response(find(group)))>mean(response(find(~group)))
        pos = 1;
    else
        pos = 0;
    end
    [~,~,~,AUC(ii)] = perfcurve(group,response,pos);

end

figure;plotHistForFC(AUC,0:0.01:1)

%%

clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'cue';
PLOT_CELL = false;

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;



lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;



    [AUCs(ii,:), ts] = AUCInTimeBin(data,EPOCH);


end


figure; hold on

for i = 1:length(req_params.cell_type)

    indType = find(strcmp(req_params.cell_type{i}, cellType));

    aveAUC = mean(AUCs(indType,:));
    semAUC = nanSEM(AUCs(indType,:));

    errorbar(ts,aveAUC, semAUC)


end
legend(req_params.cell_type)
xlabel(['time from ' EPOCH ' (ms)' ])
ylabel('AUC')

%%

function [AUCs, ts] = AUCInTimeBin(data,epoch)


[response,ind,ts] = data2response(data,epoch);

[groups, group_names] = createGroups(data,epoch,ind,false);

unique_groups = unique(groups{1});

AUCs = nan(1,length(ts));


for t=1:length(ts)


    if mean(response(t,find(groups{1}==unique_groups(1))))>mean(response(t,find(groups{1}==unique_groups(2))))
        pos = unique_groups(1);
    else
        pos = unique_groups(2);
    end
    [~,~,~,AUCs(t)] = perfcurve(groups{1},response(t,:),pos);


end
end