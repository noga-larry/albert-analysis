%% Get Data
clear

[~,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');

get_excel_info('C:\Users\noga.larry\Google Drive\PhD Projects\Vermis Reward and Movement Quantification\dataTable',...
    task_DB_path)

load (task_DB_path);
for ii=1:length(task_info)
    str_date = regexp(task_info(ii).session,'[0-9]*','match');
    task_info(ii).date = str2num(str_date{1});
    trial_num = getTrialsNumbers(task_info,ii);
    task_info(ii).num_trials = length(trial_num);
    if ~isnumeric(task_info(ii).grade)
        task_info(ii).grade = 100;
    end
    
    %task_info(ii).save_name = erase(task_info(ii).save_name,'''');
end


save ([task_DB_path '.mat'],'task_info')

%% sup_dir_from
clear
[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'SNR|BG|PC|CRB';
%req_params.task = 'choice';
req_params.remove_question_marks = 0;
%req_params.ID = 5260;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
lines = findLinesInDB (task_info, req_params);


task_info = getData('Vermis' , lines,...
    'numElectrodes',10,'includeBehavior',false);

save ([task_DB_path '.mat'],'task_info')

%%
filename = 'C:\noga\TD complex spike analysis\cell_db_noga_gil.xlsx';
A = {task_info.save_name}';
sheet = 1;
xlRange = 'X2';
xlswrite(filename,A,sheet,xlRange)


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

%% cell distribusion figure
figure;
col=[ 'b' 'k' 'r'];
types = {'PC ss','CRB','cs'}
gradeBool = [task_info.grade]<8;
ntBool = [task_info.nt]>19;
focus_task = 'pursuit_8_dir_75and25'
taskBool = strcmp({task_info.task}, focus_task);
clear Coordinates
for c = 1:length(types)
    
    
    typeBool = ~cellfun(@isempty,regexp({task_info.cell_type},types{c}));
    
    ind = find (taskBool.*typeBool.*gradeBool.*ntBool);
    
    Coordinates = struct('x', num2cell([task_info(ind).X]))
    
    temp = num2cell([task_info(ind).Y]);
    [Coordinates.y] = temp{:};
    
    temp = num2cell([task_info(ind).date])
    [Coordinates.date] = temp{:};
    
    
    Xmax = max([task_info(ind).X])
    Ymax = max([task_info(ind).Y])
    
    
    Xmin = min([task_info(ind).X])
    Ymin = min([task_info(ind).Y])
    
    % take changes in system into account
    Coordinates(find ([Coordinates.date]<190210))=[];
    T2 = find ([Coordinates.date]>190417)
    for t = T2
        Coordinates(t).y  = Coordinates(t).y + 2
    end
    
    
    x = Xmin:0.5:Xmax
    y = Ymin:0.5:Ymax
    
    
    
    
    for i = 1:length(x)
        for j=1:length(y)
            cells = find(([Coordinates.x]==x(i)) & ([Coordinates.y]==y(j)))
            if ~isempty(cells)
                
                plot(x(i),y(j),'o','MarkerSize',6*length(cells),'color',col(c)); hold on
            end
            
        end
    end
end

legend(types)

