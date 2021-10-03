%% Get Data

get_excel_info('C:\Users\Noga\Google Drive\PhD Projects\Vermis Reward and Movement Quantification\dataTable.xlsx',...
'C:\Users\Noga\Documents\Vermis Data');
load ('C:\Users\Noga\Documents\Vermis Data\task_info.mat');
for ii=1:length(task_info)
    str_date = regexp(task_info(ii).session,'[0-9]*','match');
    task_info(ii).date = str2num(str_date{1});
    if isnan(task_info(ii).grade)
        task_info(ii).grade = 7;
    end
    f_b = task_info(ii).fb_after_sort;
    f_e = task_info(ii).fe_after_sort;
    if ~isnumeric(f_b)
        f_b = str2num(f_b);
        f_e = str2num(f_e);
        trial_num = [f_b(1):f_e(1) f_b(2):f_e(2)];
    else
        trial_num = f_b:f_e;
    end
    task_info(ii).num_trials = length(trial_num);
    
end


save ('C:\Users\Noga\Documents\Vermis Data\task_info.mat','task_info')

%% sup_dir_from
clear

dataSet = 'Vermis';

[task_info,dataPath, MaestroPath,task_DB_path]...
    = loadDBAndSpecifyDataPaths(dataSet);

req_params.grade = 7;
req_params.cell_type = 'PC|BG|CRB|SNR';
%req_params.task = 'choice';
req_params.remove_question_marks = 0;
req_params.ID = 5766;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
lines = findLinesInDB (task_info, req_params);

task_info = getData('Vermis' , lines,...
    'numElectrodes',10);

save ('task_DB_path')


%% Remove spikelets 

clear

[task_info,dataPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
%req_params.task = 'choice';
req_params.remove_question_marks = 0;
%req_params.ID = 5436;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
lines = findCspkSspkPairs(task_info,req_params);

for ii=1:length(lines)
    cells = findPathsToCells (dataPath,task_info,[lines(1,ii),lines(2,ii)]);
    data = importdata(cells{1});
    data_cs = importdata(cells{2});
    
    data = removeCspkSpikelets(data,data_cs);
    save(cells{1},'data');
end

%% Remove double detections

clear

[task_info,dataPath] = loadDBAndSpecifyDataPaths('Vermis');
req_params.grade = 7;
%req_params.task = 'choice';
req_params.remove_question_marks = 0;
%req_params.ID = 5436;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
req_params.cell_type = 'PC cs';

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (dataPath,task_info,lines);

for ii=1:length(lines)
    data = importdata(cells{ii});
    
    data = removeCspkDoubleDetections(data);
    save(cells{ii},'data');
end
%% Histograms of numbers of trials

cell_types = {'PC cs', 'PC ss','CRB'};
tasks = {'choice','pursuit_8_dir_75and25', 'saccade_8_dir_75and25','speed_2_dir_0,50,100'};

req_params.grade = 7;
req_params.num_trials = 20;
req_params.remove_question_marks =0;

for i=1:length(cell_types)
    req_params.cell_type = cell_types{i};
   for j=1:length(tasks)
       req_params.task = tasks{j};
       subplot(length(cell_types),length(tasks),(length(tasks))*(i-1)+j); hold on
       [task_info] = loadDBAndSpecifyDataPaths('Golda');
       lines = findLinesInDB (task_info, req_params);
       num_trials = [task_info(lines).num_trials];
       plotHistForFC(num_trials,15,'cdf', 'unNormalized','r*')
       [task_info] = loadDBAndSpecifyDataPaths('Vermis');
       lines = findLinesInDB (task_info, req_params);
       num_trials = [task_info(lines).num_trials];
       plotHistForFC(num_trials,15,'cdf', 'unNormalized','b*')
       title([tasks{j} ', ' cell_types{i}],'Interpreter', 'none')
       
   end
end

legend('Golda','Albert')
%% Pairs
clear req_params
[task_info,sup_dir_to,sup_dir_from, path_to_task_info] = ...
    loadDBAndSpecifyDataPaths('Vermis');
req_params.grade = 7;
req_params.remove_question_marks = 0;
req_params.num_trials = 50;
req_params.remove_repeats = false; 

task_info = listSimultaneousPairs(task_info,req_params);
save (path_to_task_info,'task_info')

clear req_params
%req_params.task = {'pursuit_8_dir_75and25'};
req_params.grade = 7;
req_params.remove_question_marks = 0;
req_params.num_trials = 50;
req_params.remove_repeats = 0;

req_params.cell_type = 'BG';
lines1 = findLinesInDB (task_info, req_params);
req_params.cell_type = 'PC ss|CRB'
lines2 = findLinesInDB (task_info, req_params);

pairs = findPairs(task_info,lines1,lines2,req_params.num_trials)