clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'cue';
PLOT_CELL = false;

req_params = reqParamsEffectSize("both");

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;



    [fracSig(ii,:,:), ts] = fracSigInTimeBin(data,EPOCH);


end

%%
figure; 

for t = 1:size(fracSig,2)

    subplot(size(fracSig,2),1,t); hold on
    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        ave = squeeze(mean(fracSig(indType,t,:)));
        sem = squeeze(nanSEM(fracSig(indType,t,:)));

        errorbar(ts,ave, sem)


    end

    legend(req_params.cell_type)
    xlabel(['time from ' EPOCH ' (ms)' ])
    ylabel('frac sig')
end



%%

function [fracSig, ts] = fracSigInTimeBin(data,epoch)


[response,ind,ts] = data2response(data,epoch);

switch epoch
    case 'cue'
        [~,groups] = getProbabilities(data,ind,'omitNonIndexed',true);
    case 'reward'
        groups = getOutcome(data,ind,'omitNonIndexed',true);

end

unique_groups = unique(groups);

fracSig = nan(1,length(ts));


for t=1:length(ts)

    
    cond1 = response(t,find(groups==unique_groups(1)));

    cond2 = response(t,find(groups==unique_groups(2)));

    fracSig(1,t) = ranksum(cond1,cond2,tail="right")<0.05; % cond 1 is larger
    fracSig(2,t) = ranksum(cond1,cond2,tail="left")<0.05;

end
end