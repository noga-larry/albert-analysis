%% Behavior figure

MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4500:5000;
req_params.num_trials = 50;
req_params.remove_question_marks =0;

behavior_params.time_after = 600;
behavior_params.time_before = 100;
bink_margin = 70;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


directions = 0:45:315;
time_window = (-behavior_params.time_before:behavior_params.time_after);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    Hbehavior = nan(length(data.trials),length(time_window));
    Vbehavior = nan(length(data.trials),length(time_window));
    
    for t = 1:length(data.trials)
        if data.trials(t).fail
            continue
        end
        
        Hb = data.trials(t).extended_hPos;
        Vb = data.trials(t).extended_vPos;
        
        %remove blinks
        
        Hb = removesSaccades(Hb,data.trials(t).extended_blink_begin,...
            data.trials(t).extended_blink_end);
        Vb = removesSaccades(Vb,data.trials(t).extended_blink_begin,...
            data.trials(t).extended_blink_end);
        
        ts = data.trials(t).rwd_time_in_extended + time_window;
        
        
        
        Hbehavior(t,:) = Hb(ts);
        Vbehavior(t,:) = Vb(ts);
        
    end
    
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    [~,match_d] = getDirections(data);
    
    indLow = find (match_p == 25 & (~boolFail));
    indHigh = find (match_p == 75 & (~boolFail));
    
    for d=1:length(directions)
        
        inxL = intersect(find (match_d == directions(d)),indLow);
        inxH = intersect(find (match_d == directions(d)),indHigh);
        
        subplot(8,2,2*d-1)
        plot(Hbehavior(inxL,:)','r'); hold on
        plot(Hbehavior(inxH,:)','b'); hold on
        title (['d = ' num2str(directions(d)),' H'])
        
        
        subplot(8,2,2*d)
        plot(Vbehavior(inxL,:)','r'); hold on
        plot(Vbehavior(inxH,:)','b'); hold on
        title (['d = ' num2str(directions(d)),' V'])
        
    end
    
end
