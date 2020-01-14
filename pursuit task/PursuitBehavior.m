%% Behavior figure

clear all

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    velLow(ii,:) = meanVelocitiesRotated(data,behavior_params,indLow);
    velHigh(ii,:) = meanVelocitiesRotated(data,behavior_params,indHigh);
    
end

aveLow = mean(velLow);
semLow = std(velLow)/sqrt(length(cells));
aveHigh = mean(velHigh);
semHigh = std(velHigh)/sqrt(length(cells));

figure
errorbar(aveLow,semLow,'r'); hold on
errorbar(aveHigh,semHigh,'b')

figure
scatter(mean(velHigh(:,200:250),2),mean(velLow(:,200:250),2))
xlabel('High');ylabel('Low')
refline(1,0)
