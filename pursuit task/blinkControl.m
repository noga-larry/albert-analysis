clear

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

TASK= "both";
MONKEY = "both";
EPOCH = 'reward';
req_params = reqParamsEffectSize(TASK,MONKEY);

behavior_params.time_after = 500;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 0; % ms

windowEvent = -behavior_params.time_before:behavior_params.time_after;


lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);
cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;


    data = getExtendedBehavior(data,supPath);

    cellID(ii) = data.info.cell_ID;

    boolFail = [data.trials.fail];
    inx = find(~boolFail);
    [~,mat] = eventRate(data,'extended_blink_begin','reward',...
        inx,windowEvent,[]);


    boolBlink = nan(1,length(data.trials));

    boolBlink(find(boolFail)) = 0; % fail
    boolBlink(inx(find(sum(mat,2)==0))) = 1; %no blink
    boolBlink(inx(find(sum(mat,2)>0))) = 2; % blink

    assert(~any(isnan(boolBlink)))
    assert(length(boolBlink)==length(data.trials))
    
    disp(mean(boolBlink==1))
    dataNoBlink.trials = data.trials(find(boolBlink==1));
    dataBlink.trials = data.trials(find(boolBlink==2));

    dataNoBlink.info = data.info;
    dataBlink.info = data.info;

    [effectSizesBlink(ii,:),ts] = effectSizeInTimeBin...
        (dataBlink,EPOCH);

    [effectSizesNoBlink(ii,:),ts] = effectSizeInTimeBin...
        (dataNoBlink,EPOCH);

end


%%

flds = fields(effectSizesBlink);


h = cellID<inf% & rel

figure; c=1;
for f = 1:length(flds)

    subplot(length(flds),2,c); hold on

    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        a = reshape([effectSizesBlink(indType,:).(flds{f})],length(indType),length(ts));

        errorbar(ts,nanmean(a,1), nanSEM(a,1))

    end
    xlabel(['time from ' EPOCH ' (ms)' ])
    title([flds{f} '- blink'], 'Interpreter', 'none')
    c=c+1;
    subplot(length(flds),2,c); hold on
    for i = 1:length(req_params.cell_type)

        indType = find(strcmp(req_params.cell_type{i}, cellType));

        a = reshape([effectSizesNoBlink(indType,:).(flds{f})],length(indType),length(ts));
        errorbar(ts,nanmean(a,1), nanSEM(a,1))

    end
    
    xlabel(['time from ' EPOCH ' (ms)' ])
    title([flds{f} ' -  No blink' ], 'Interpreter', 'none')
    legend(req_params.cell_type)
    c=c+1;
end