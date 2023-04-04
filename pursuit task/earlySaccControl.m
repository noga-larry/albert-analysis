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
