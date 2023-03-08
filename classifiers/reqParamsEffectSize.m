function req_params = reqParamsEffectSize(task,monkey)

if nargin<2 || monkey=="both"
    req_params.ID = 4000:6000;
elseif monkey=="albert"
    req_params.ID = 4000:5000;
elseif monkey=="golda"
    req_params.ID = 5000:6000;
else
    return
end


if task=="saccade"
    req_params.task = 'saccade_8_dir_75and25';
elseif task=="pursuit"
    req_params.task = 'pursuit_8_dir_75and25';
elseif task=="both"
    req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
end

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.num_trials = 100;
req_params.remove_question_marks = 1;
