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

    [effectSizesSac(ii,:),ts] = effectSizeInTimeBin...
        (dataSac,EPOCH);

    [effectSizesNoSac(ii,:),ts] = effectSizeInTimeBin...
        (dataNoSac,EPOCH);

end