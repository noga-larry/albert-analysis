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



%% Get Data FLOC
clear

[~,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Floc');

get_excel_info('C:\Users\noga.larry\Google Drive\PhD Projects\Vermis Reward and Movement Quantification\cell_db_for_merav',...
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
%%

[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Floc');

req_params.grade = 7;
%req_params.cell_type = 'SNR';
req_params.task = 'rwd_direction_tuning';
req_params.cell_type = {'PC cs'};
req_params.remove_question_marks = 0;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
lines = findLinesInDB (task_info, req_params);

task_info = getData('Floc' , lines,...
    'numElectrodes',5,'includeBehavior',false);

save ([task_DB_path '.mat'],'task_info')

%%
clear; clc

[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Floc');

for i=1:length(task_info)
    if contains(task_info(i).cell_type,'SNR') & contains(task_info(i).cell_type,'?')
        task_info(i).cell_type = 'SNR';
    elseif strcmp(task_info(i).cell_type,'SNR ')
        task_info(i).cell_type = 'SNR';
    elseif strcmp(task_info(i).cell_type,'BG tan ')
        task_info(i).cell_type = 'BG tan';
    elseif strcmp(task_info(i).cell_type,'PC ss '  )
        task_info(i).cell_type = 'PC ss';        
    elseif strcmp(task_info(i).cell_type,'PC cs ' )
        task_info(i).cell_type = 'PC cs';
    elseif strcmp(task_info(i).cell_type,'CRB ' )
        task_info(i).cell_type = 'CRB';
    end
end
uniqueRowsCA({task_info.cell_type}')
save ([task_DB_path '.mat'],'task_info')



%% get Data
clear
DATASET = 'Vermis';
[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths(DATASET);

req_params = reqParamsEffectSize("both");
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn','PC cs'};
req_params.ID = 4006;

lines = findLinesInDB (task_info, req_params);

task_info = getData(DATASET , lines,...
    'numElectrodes',10,'includeBehavior',false);

save ([task_DB_path],'task_info')

%% bahvior shadow files
clear
[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn','PC cs'};
%req_params.ID = 4006;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (dataPath,task_info,lines);


for i=1:length(lines)
    
    
    data = importdata(cells{i});
    
    if isfield(data.trials,'hPos')
        continue
    end
    
    behavior_data = getBehaviorShadowFile(data,MaestroPath);
    
    behavior_name = [erase(data.info.save_name,'.mat')...
        ' behavior.mat'];
    path = [dataPath '\' data.info.task '\behavior\' behavior_name];
    
    if ~isfolder([dataPath '\' data.info.task '\behavior\'])
        mkdir([dataPath '\' data.info.task '\behavior\'])
    end
    save(path,'behavior_data')
    
    data.info.behavior_shadow_name = behavior_name;
    
    task_info(lines(i)).behavior_shadow_name = behavior_name;
    
    save(cells{i},'data')
    
end
    
save ([task_DB_path],'task_info')

%% extended behavior calibaration

clear
[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');
d = dir(dataPath); d = d(3:end);
dfolders = d([d(:).isdir]);

c=1;

for d=1:length(dfolders)
    
    files = dir([dataPath '\' dfolders(d).name]); files = files(3:end);
    files = files(~[files(:).isdir]);
    for i = 1:length(files)
        
        files = dir([dataPath '\' dfolders(d).name]); files = files(3:end);
        files = files(~[files(:).isdir]);
        
        if files(i).name(1:2)=='al' | files(i).name(1:2)=='go'
            continue
        end
        paths{c} = [dataPath '\' dfolders(d).name '\' files(i).name];
        
        
        c = c+1;
    end
end

for i=1:length(paths)
       
        load(paths{i});      
        %data = importdata(paths{i});        
        
        
        data = caliberateExtendedBehavior ...
            (data,dataPath,MaestroPath);

        save(paths{i},'data')
        
        if rem(i,50)==0
            disp([num2str(i) '/' num2str(length(paths))])
        end

    
end

%%
clear
[task_info,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn','PC cs'};
%req_params.ID = 4006;


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (dataPath,task_info,lines);

for i=1:length(lines)
    
    
    data = importdata(cells{i});
    
    if isfield(data.trials,'hPos')
        continue
    end
    
    [extended_behavior_data] = getExtendedBehaviorShadowFile(data,MaestroPath);
    
    behavior_name = [erase(data.info.save_name,'.mat')...
        ' extended behavior.mat'];
    path = [dataPath '\' data.info.task '\extended behavior\' behavior_name];

    if ~isfolder([dataPath '\' data.info.task '\extended behavior\'])
        mkdir([dataPath '\' data.info.task '\extended behavior\'])
    end

    save(path,'extended_behavior_data')
    
    data.info.extended_behavior_shadow_name = behavior_name;
    
    task_info(lines(i)).extended_behavior_shadow_name = behavior_name;
    
    save(cells{i},'data')
    
end
    
save ([task_DB_path],'task_info')



%%
clear
[~,dataPath, MaestroPath,task_DB_path] =...
    loadDBAndSpecifyDataPaths('Vermis');

d = dir([MaestroPath '\albert']); d = d(23:97);
prefix = {d.name};
task_info = listSessionsFromTrials(MaestroPath,prefix)

req_params.num_trials = 20;
req_params.remove_repeats =false;
lines = findLinesInDB (task_info, req_params);
task_info = getData('Albert behavior before recording' , lines);
%%
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Golda behavior before recording');

req_params.num_trials = 20;
req_params.remove_repeats =false;
lines = findLinesInDB (task_info, req_params);
lines(142)=[];
for i =1:length(lines)
    data = importdata([supPath '\' task_info(lines(i)).task '\' task_info(lines(i)).save_name '.mat']);
    task_info(lines(i)).probabilities = getProbabilities(data);
    task_info(lines(i)).directions = getDirections(data);
end

%% Remove spikelets 

clear

[task_info,dataPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params = reqParamsEffectSize("both");
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

lines = findCspkSspkPairs(task_info,req_params);

for ii=1:length(lines)
    cells = findPathsToCells (dataPath,task_info,[lines(1,ii),lines(2,ii)]);
    data = importdata(cells{1});
    data_cs = importdata(cells{2});
    
    data = removeCspkSpikelets(data,data_cs);
    save(cells{1},'data');
end

%% Remove CS double detections

clear

[task_info,dataPath] = loadDBAndSpecifyDataPaths('Vermis');
req_params = reqParamsEffectSize("both");
req_params.remove_repeats = 0;
req_params.cell_type = 'PC cs';

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (dataPath,task_info,lines);
NUM_REPEATS = 3 ;

for ii=1:length(lines)
    data = importdata(cells{ii});
    
    for j=1:NUM_REPEATS
        data = removeCspkDoubleDetections(data);
    end
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

req_params.cell_type = 'BG|SNR';
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
    
    
    x = Xmin:0.5:Xmax;
    y = Ymin:0.5:Ymax;
    
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


%% 

clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');


req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25|choice';
req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.num_trials = 50;
req_params.remove_repeats = false;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);

for ii = 1:length(cells)

    data = importdata(cells{ii});
    if task_info(lines(ii)).num_trials ~= length(data.trials)
    task_info(lines(ii)).num_trials = length(data.trials);
    disp('Wrong')
    end
           
end

save ([task_DB_path '.mat'],'task_info')
