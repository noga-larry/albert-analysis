%% Get Data

get_excel_info('C:\Users\noga.larry\Google Drive\PhD Projects\Vermis Reward and Movement Quantification\cell_db_noga_gil.xlsx',...
    'C:\Users\noga.larry\Documents\Vermis Data')
load ('C:\Users\noga.larry\Documents\Vermis Data\task_info');
for ii=1:length(task_info)
    str_date = regexp(task_info(ii).session,'[0-9]*','match');
    task_info(ii).date = str2num(str_date{1});
    if ~isnumeric(task_info(ii).grade)
        task_info(ii).grade = 100;
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
    
    %task_info(ii).save_name = erase(task_info(ii).save_name,'''');
end


save ('C:\Users\noga.larry\Documents\Vermis Data\task_info')

%% sup_dir_from
clear
[task_info] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'SNR|BG|PC|CRB';
%req_params.task = 'speed_2_dir_0,50,100';
req_params.remove_question_marks = 0;
req_params.ID = 4000:5000;
req_params.remove_question_marks = 0;
req_params.num_trials = 20;
req_params.remove_repeats = 0;
lines = findLinesInDB (task_info, req_params);


sup_dir_from = 'G:\DATA';
sup_dir_to = 'C:\Users\noga.larry\Documents\Vermis Data\';

task_info = getData('Vermis' , lines,...
    'numElectrodes',10);

save('C:\Users\noga.larry\Documents\Vermis Data\task_info','task_info')


filename = 'C:\noga\TD complex spike analysis\cell_db_noga_gil.xlsx';
A = {task_info.save_name}';
sheet = 1;
xlRange = 'X2';
xlswrite(filename,A,sheet,xlRange)

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



%%

dir_data_from = 'C:\noga\TD complex spike analysis\Maestro Data';
dir_data_to = 'C:\noga\TD complex spike analysis\Data'
monkey = 'albert'
focus_task = 'pursuit_8_dir_75and25';
get_data(task_info, dir_data_from, dir_data_to, monkey, focus_task)
get_extended_data(dir_data_from, dir_data_to)
%%
% raster params
raster_params.time_after = 1000; % ms, time after cue appearance of display.
raster_params.time_before = 399; % ms, time before cue appearance of display.
raster_params.plot_cell = 0; % whether or not to plot individual cells rasters and psths
effect_window = (100:300) + raster_params.time_before; % time window to average the effect in (used in scatter plot and statistica tests)
raster_params.include_failed = 1; % include failed trials
raster_params.smoothing_margins = 100; % ms
raster_params.SD = 10;

