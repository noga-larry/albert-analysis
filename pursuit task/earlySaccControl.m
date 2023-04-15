%% remove saccades

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

DIRECTIONS = 0:45:315;
windowEvent = 0:400;
EPOCH = 'reward';

req_params = reqParamsEffectSize("pursuit");
lines_pursuit = findLinesInDB (task_info, req_params);

req_params = reqParamsEffectSize("saccade");
lines_saccade = findLinesInDB (task_info, req_params);

lines = findSameNeuronInTwoLinesLists(task_info,lines_pursuit,lines_saccade);

for ii = 1:length(lines)

    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    data_pur = importdata(cells{1}); data_sacc= importdata(cells{2});
    data_pur = getExtendedBehavior(data_pur,supPath);
    data_sacc = getExtendedBehavior(data_sacc,supPath);

    data.info = data_pur.info;
    data.trials = data_pur.trials;
    data.trials(end+1:end+length(data_sacc.trials)) = data_sacc.trials;

    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;

    boolFail = [data.trials.fail];
    inx = find(~boolFail);
    [~,mat] = eventRate(data,'extended_saccade_begin','reward',...
        inx,windowEvent,[]);

    boolSacc = nan(1,length(data.trials));

    boolSacc(find(boolFail)) = 0; % fail
    boolSacc(inx(find(sum(mat,2)==0))) = 1; %no sacc
    boolSacc(inx(find(sum(mat,2)>0))) = 2; % sacc

    assert(~any(isnan(boolSacc)))
    assert(length(boolSacc)==length(data.trials))

    disp([num2str(mean(boolSacc==1)) ' - ' num2str(sum(boolSacc==1))])
    dataNoSac.trials = data.trials(find(boolSacc==1));
    dataSac.trials = data.trials(find(boolSacc==2));

    dataNoSac.info = data.info;
    dataSac.info = data.info;

    %     [effectSizesSac(ii,:),ts] = effectSizeInTimeBin...
    %         (dataSac,EPOCH);

    [effects(ii)] = effectSizeInEpoch(dataNoSac,EPOCH);

    %     [effectSizesNoSac(ii,:),ts] = effectSizeInTimeBin...
    %         (dataNoSac,EPOCH);

end


%%

flds = fields(effectSizesSac);


h = cellID<inf% & rel

figure; c=1;
for f = 1:length(flds)

    subplot(length(flds),2,c); hold on

    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        a = reshape([effectSizesSac(indType,:).(flds{f})],length(indType),length(ts));

        errorbar(ts,nanmean(a,1), nanSEM(a,1))

    end
    xlabel(['time from ' EPOCH ' (ms)' ])
    title([flds{f} '- sacc'], 'Interpreter', 'none')
    c=c+1;
    subplot(length(flds),2,c); hold on
    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        a = reshape([effectSizesNoSac(indType,:).(flds{f})],length(indType),length(ts));
        errorbar(ts,nanmean(a,1), nanSEM(a,1))

    end

    xlabel(['time from ' EPOCH ' (ms)' ])
    title([flds{f} ' -  No sacc' ], 'Interpreter', 'none')
    legend(req_params.cell_type)
    c=c+1;
end

%%

f = 'reward_outcome';
for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    x = [effects(indType).(f)];
    p = bootstrapTTest(x);
    disp([req_params.cell_type{i} ': ' num2str(p)])
end


%% equalize saccade dist

clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms
windowEvent = 0:400;

req_params = reqParamsEffectSize("both");
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(lines)

    data = importdata(cells{ii});
    data = getExtendedBehavior(data,supPath);

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    data = equateDistributions(data,windowEvent);

    
    [effectSizesSac(ii,:),ts] = effectSizeInTimeBin...
        (data,'reward');

    [effects(ii)] = effectSizeInEpoch(data,'reward');

    saccadeRate(ii,:,:) = saccRate(data,behavior_params);
end

%%

figure; hold on

ts_behavior = -behavior_params.time_before:behavior_params.time_after;

for i=1:size(saccadeRate,2)
    ave = squeeze(mean(saccadeRate(:,i,:)));
    sem = squeeze(nanSEM(saccadeRate(:,i,:)));
    errorbar(ts_behavior,ave,sem)
end

legend({'P=25 R','P=75 R','P=25 NR','P=75 NR'})
xlabel('time from outcome'); ylabel('sacc rate')

figure;
f = 'reward_outcome';
for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    x = [effects(indType).(f)];
    p = bootstrapTTest(x);
    disp([req_params.cell_type{i} ': ' num2str(p)])
end


flds = fields(effectSizesSac);


h = cellID<inf;% & rel

for f = 1:length(flds)

    subplot(length(flds),1,f); hold on

    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        a = reshape([effectSizesSac(indType,:).(flds{f})],length(indType),length(ts));

        errorbar(ts,nanmean(a,1), nanSEM(a,1))

    end
    xlabel(['time from outcome (ms)' ])
    title([flds{f}], 'Interpreter', 'none')
  
    legend(req_params.cell_type)
end

%%
function data = equateDistributions(data,windowEvent)
boolFail = [data.trials.fail];

data.trials(find(boolFail))=[];

match_o = getOutcome(data);
[~,mat] = eventRate(data,'extended_saccade_begin','reward',...
    1:length(data.trials),windowEvent,[]);
boolSacc = zeros(1,length(data.trials));
boolSacc((sum(mat,2)>0)) = 1; % sacc


ratio_before = sum(boolSacc & match_o)/sum(match_o)...
    /(sum(boolSacc & ~match_o)/sum(~match_o));

saccDiff = sum(boolSacc & match_o) - sum(boolSacc & ~match_o);

if saccDiff>0
    inx = find(boolSacc & match_o);
    inx = inx(randperm(length(inx),randRound(saccDiff/2)));
    for j=1:length(inx)
        data.trials(inx(j)).name = replace(data.trials(inx(j)).name,'R','NR');
    end
else
    inx = find(boolSacc & ~match_o);
    inx = inx(randperm(length(inx),randRound(-saccDiff/2)));
    for j=1:length(inx)
        data.trials(inx(j)).name = replace(data.trials(inx(j)).name,'NR','R');
    end
end

saccDiff = sum(~boolSacc & ~match_o) - sum(~boolSacc & match_o);

if saccDiff>0
    inx = find(~boolSacc & ~match_o);
    inx = inx(randperm(length(inx),randRound(saccDiff/2)));
    for j=1:length(inx)
        data.trials(inx(j)).name = replace(data.trials(inx(j)).name,'NR','R');
    end
else
    inx = find(~boolSacc & match_o);
    inx = inx(randperm(length(inx),randRound(-saccDiff/2)));
    for j=1:length(inx)
        data.trials(inx(j)).name = replace(data.trials(inx(j)).name,'R','NR');
    end
end

match_o = getOutcome(data);
[~,mat] = eventRate(data,'extended_saccade_begin','reward',...
    1:length(data.trials),windowEvent,[]);
boolSacc = zeros(1,length(data.trials));
boolSacc((sum(mat,2)>0)) = 1; % sacc
ratio_after = sum(boolSacc & match_o)/sum(match_o)...
    /(sum(boolSacc & ~match_o)/sum(~match_o));

disp([num2str(ratio_before) ' - ' num2str(ratio_after)])

end

%%

function saccadeRate = saccRate(data,behavior_params)


windowEvent = -behavior_params.time_before:behavior_params.time_after;

[match_o] = getOutcome (data);
boolFail = [data.trials.fail];

indR = find (match_o == 1 &(~boolFail));
indNR = find (match_o == 0 &(~boolFail));

inx = {indR,indNR};

for j=1:length(inx)

    saccadeRate(j,:) = eventRate(data,'extended_saccade_begin','reward',inx{j},windowEvent,behavior_params.SD);

end
end
