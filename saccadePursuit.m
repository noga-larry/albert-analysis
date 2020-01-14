load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
pursuitIDs = [task_info(lines).cell_ID];

req_params.task = 'saccade_8_dir_75and25';
lines = findLinesInDB (task_info, req_params);
saccadeIDs = [task_info(lines).cell_ID];

IDs = intersect(pursuitIDs,saccadeIDs);


for ii=1:length(IDs)
   req_params.ID = IDs(ii);
   req_params.task = 'pursuit_8_dir_75and25';
   lines = findLinesInDB (task_info, req_params);

   tuning(ii).pursuit_h = task_info(lines).directionally_tuned;
   tuning(ii).pursuit_PD = task_info(lines).PD;
   
   req_params.task = 'saccade_8_dir_75and25';
   lines = findLinesInDB (task_info, req_params);

   tuning(ii).saccade_h = task_info(lines).directionally_tuned;
   tuning(ii).saccade_PD = task_info(lines).PD;
     
end

sum([tuning.pursuit_h] & [tuning.saccade_h])
sum(~[tuning.pursuit_h] & [tuning.saccade_h])
sum([tuning.pursuit_h] & ~[tuning.saccade_h])

angles = wrapTo180([tuning.pursuit_PD]-[tuning.saccade_PD])'
intervals = 45;
[counts,centers] = hist(angles,-180:intervals:180);
plot(centers, counts/length(IDs)); hold on



