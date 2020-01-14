MaestroPath = 'C:\Users\Owner\Desktop\DATA\albert\';
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 10;
req_params.cell_type = 'CRB|PC';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000
%[4122, 4146,4143,4250,4251,4267, 4270, 4291,4582,4611,4706,4711,4821,4847,4870];
req_params.num_trials = 10;
req_params.remove_question_marks =0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    if  ~(task_info(lines(ii)).extended_behavior_fit==1) ;
        continue
    end
    
    data = importdata(cells{ii});
    data = getExtendedBehavior(data,MaestroPath);
    
    for t=1:length(data.trials)
        
        extH = [data.trials(t).extended_hPos((data.trials(t).rwd_time_in_extended:end))];
        extV = [data.trials(t).extended_vPos((data.trials(t).rwd_time_in_extended:end)];
        maeH = [data.trials(t).hPos];
        maeV = [data.trials(t).vPos];
        
        beginSaccade = data.trials(t).beginSaccade;
        endSaccade = data.trials(t).endSaccade;
        
        extH = removesSaccades( extH, beginSaccade, endSaccade );
        extV = removesSaccades( extV, beginSaccade, endSaccade );
        maeH = removesSaccades( maeH, beginSaccade, endSaccade );
        maeV = removesSaccades( maeV, beginSaccade, endSaccade );
        
        if any(abs(extH-maeH)>10) | any(abs(extV-maeV)>10)
            
            subplot(2,1,1)
            plot(extH,'*'); hold on
            plot(maeH,'*'); hold off
            subplot(2,1,2)
            plot(extV,'*'); hold on
            plot(maeV,'*'); hold off
            suptitle(data.trials(t).maestro_name)
            pause
        end
        
    end
end