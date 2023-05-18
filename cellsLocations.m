clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'SNR'};
req_params.num_trials = 50;
req_params.ID = 4000:5000;
req_params.task = {'choice|saccade_8_dir_75and25|pursuit_8_dir_75and25'};

lines = findLinesInDB(task_info, req_params);

median([task_info(lines).X])
median([task_info(lines).Y])

median([task_info(lines).depth_mm])
GUIDE_FROM_CAHMBER_TOP = 23 *1000;

%%

imag = imread('C:\Users\noga.larry\Google Drive\PhD Projects\Vermis Reward and Movement Quantification\MRI figures\111026057.png');



figure; imagesc(imag); axis square