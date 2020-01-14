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
behavior_params.time_before = 100;
behavior_params.SD = 10;

bink_margin = 70;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


directions = 0:45:315;
time_window = (-behavior_params.time_before:behavior_params.time_after);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    [~,match_d] = getDirections (data);
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    vVel = nan(length(data.trials),length(time_window));
    hVel = nan(length(data.trials),length(time_window));
    
    for t = 1:length(data.trials)
        if data.trials(t).fail
            continue
        end
        
        traceH = data.trials(t).extended_hVel;
        traceV = data.trials(t).extended_vVel;
        theta = -data.trials(t).screen_rotation - match_d(t);
        
        [rotatedTraceH,rotatedTraceV] = rotateEyeMovement(traceH, traceV, theta);
        
        rotatedTraceH = rotatedTraceH((data.trials(t).extended_trial_begin+1):data.trials(t).rwd_time_in_extended);
        rotatedTraceV = rotatedTraceV((data.trials(t).extended_trial_begin+1):data.trials(t).rwd_time_in_extended);
        
        hVel_raw = removesSaccades(rotatedTraceH,data.trials(t).beginSaccade,data.trials(t).endSaccade );
        vVel_raw = removesSaccades(rotatedTraceV,data.trials(t).beginSaccade,data.trials(t).endSaccade );
        
        ts = data.trials(t).movement_onset+time_window;
        vVel_raw = vVel_raw(ts);
        hVel_raw = hVel_raw(ts);
        
        vVel(t,:) = vVel_raw;
        hVel(t,:) = hVel_raw;
        
        
    end
    
    hVelLow(ii,:) = gaussSmooth(nanmean(hVel(indLow,:)),behavior_params.SD);
    vVelLow(ii,:) = gaussSmooth(nanmean(vVel(indLow,:)),behavior_params.SD);
    
    hVelHigh(ii,:) = gaussSmooth(nanmean(hVel(indHigh,:)),behavior_params.SD);
    vVelHigh(ii,:) = gaussSmooth(nanmean(vVel(indHigh,:)),behavior_params.SD);
    
end

aveLow = mean(velLow);
semLow = std(velLow)/sqrt(length(cells));
aveHigh = mean(velHigh);
semHigh = std(velHigh)/sqrt(length(cells));

errorbar(aveLow,semLow,'r'); hold on
errorbar(aveHigh,semHigh,'b')