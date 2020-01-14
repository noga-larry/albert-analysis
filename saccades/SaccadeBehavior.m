%% Behavior figure

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\saccade_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = [4000:5000];
req_params.num_trials = 50;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);
directions = [0:45:315];
for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    [~,match_d] = getDirections (data);
    
    
    for d=1:length(directions)
        indLow = find (match_p == 25 & (~boolFail) & match_d==directions(d));
        indHigh = find (match_p == 75 & (~boolFail)& match_d==directions(d));
        RTLow(ii,d) = nanmean(saccadeRTs(data,indLow));
        RTHigh(ii,d) = nanmean(saccadeRTs(data,indHigh));

    end
    
    
end

%%
aveLow = nanmean(RTLow);
semLow = nanstd(RTLow)/sqrt(length(cells));
aveHigh = nanmean(RTHigh);
semHigh = nanstd(RTHigh)/sqrt(length(cells));

errorbar(aveLow,semLow,'r'); hold on
errorbar(aveHigh,semHigh,'b')
for d = 1:size(directions,2)
    tix{d} = [num2str(directions(d))];
end
xticklabels(tix)
ylabel('RT')
xlabel('Direction')
legend('25','75')


%%

figure;

plot(data.trials(ind(t)).hPos); hold on
plot(data.trials(ind(t)).beginSaccade,data.trials(ind(t)).hPos(data.trials(ind(t)).beginSaccade),'*k'); 
plot(data.trials(ind(t)).endSaccade,data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade),'*r'); 
plot(data.trials(ind(t)).vPos); hold on
plot(data.trials(ind(t)).beginSaccade,data.trials(ind(t)).vPos(data.trials(ind(t)).beginSaccade),'*k'); 
plot(data.trials(ind(t)).endSaccade,data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade),'*r'); s