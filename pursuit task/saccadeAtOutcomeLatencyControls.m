clear

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');

TASK= "both";
MONKEY = "albert";
req_params = reqParamsEffectSize(TASK,MONKEY);

behavior_params.time_after = 1500;
behavior_params.time_before = 1000;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

ts = -behavior_params.time_before:behavior_params.time_after;
DIRECTIONS = 0:45:360;

windowEvent = -behavior_params.time_before:behavior_params.time_after;


lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)

    data = importdata(cells{ii});
    data = getExtendedBehavior(data,supPath);

    cellID(ii) = data.info.cell_ID;

    % direction distribution of saccade
    % amplitude

    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    boolFail = [data.trials.fail];

    indLowR = find (match_p == 25 & match_o == 1 &(~boolFail));
    indHighR = find (match_p == 75 & match_o == 1 & (~boolFail));
    indLowNR = find (match_p == 25 & match_o == 0 &(~boolFail));
    indHighNR = find (match_p == 75 & match_o == 0 &(~boolFail));

    inx = {indLowR,indHighR,indLowNR,indHighNR};

    for j=1:length(inx)


        rateBlink(ii,j,:) = eventRate(data,'extended_blink_begin','reward',inx{j},windowEvent);
        saccadeRate(ii,j,:) = eventRate(data,'extended_saccade_begin','reward',inx{j},windowEvent);

        [ampitudes(ii,j,:),endPoints(ii,j,:,:)] = saccParams(data,inx{j});

    end

end

%%

figure;
subplot(2,2,1); hold on

for i=1:size(saccadeRate,2)
    ave = squeeze(mean(rateBlink(:,i,:)));
    sem = squeeze(nanSEM(rateBlink(:,i,:)));
    errorbar(ts,ave,sem)
end

legend({'P=25 R','P=75 R','P=25 NR','P=75 NR'})
xlabel('time from outcome'); ylabel('blink rate')

subplot(2,2,2); hold on
for i=1:size(saccadeRate,2)
    ave = squeeze(mean(saccadeRate(:,i,:)));
    sem = squeeze(nanSEM(saccadeRate(:,i,:)));
    errorbar(ts,ave,sem)
end

legend({'P=25 R','P=75 R','P=25 NR','P=75 NR'})
xlabel('time from outcome'); ylabel('sacc rate')

subplot(2,2,3); hold on
for i=1:size(endPoints,2)
    h = endPoints(:,i,:,1);
    v = endPoints(:,i,:,2);
    scatter(h(:),v(:),'filled')
end
legend({'P=25 R','P=75 R','P=25 NR','P=75 NR'})

subplot(2,2,4); hold on
for i=1:size(ampitudes,2)
    x = ampitudes(:,i,:);
    plotHistForFC(x,0:30)
end
legend({'P=25 R','P=75 R','P=25 NR','P=75 NR'})
sgtitle(TASK + " , " + MONKEY)
%%

function [amp,endPoint] = saccParams(data,ind)

DIRECTIONS = 0:45:315;
amp = nan(length(DIRECTIONS),1);
endPoint = nan(length(DIRECTIONS),2);
[~,match_d] = getDirections(data);

for d=1:length(DIRECTIONS)
    indDir = intersect(ind,find(match_d==DIRECTIONS(d)));
    ampDir = nan(length(indDir),1);
    endPointDir = nan(length(indDir),2);
    for t=1:length(indDir)
        saccInx = findFirstSacc(data,indDir(t));
        if isnan(saccInx)
            continue
        end
        hPos = data.trials(indDir(t)).hPos;
        vPos = data.trials(indDir(t)).vPos;
        tb = data.trials(indDir(t)).extended_saccade_begin(saccInx);
        te = data.trials(indDir(t)).extended_saccade_end(saccInx);
        ampDir(t) = sqrt((hPos(te)-hPos(tb))^2+(vPos(te)-vPos(tb))^2);
        endPointDir(t,:) = [hPos(te),vPos(te)];
        if ampDir(t)>100 || any(abs((endPointDir(t,:)))>100)
            disp('Weird saccade')
            ampDir(t) = nan;
            endPointDir(t,:) = [nan,nan];
        end
    end
amp(d) = mean(ampDir,'omitnan');
endPoint(d,:) = mean(endPointDir,1,'omitnan');

end
end

%%
function saccInx = findFirstSacc(data,ind)

    saccadesAlignedToReward = data.trials(ind).extended_saccade_begin...
        -data.trials(ind).rwd_time_in_extended;
    i = find(saccadesAlignedToReward>0,1);
    if isempty(i)
        disp('No saccade')
        saccInx= nan;
        return
    end
    saccInx= i;

end

