
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
PLOT_CELL = false;


req_params = reqParamsEffectSize("saccade");


% req_params.grade = 7;
% req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
% req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
% %req_params.task = 'rwd_direction_tuning';
% req_params.num_trials = 100;
% req_params.remove_question_marks = 1;

%pursuit
ID_cs_sig = [4322	4328	4455	4457	4582	4610	4810	4825	4851	4942	5156	5358	5381	5434	5458	5620	5696];
%saccades
ID_cs_sig = [4238	4239	4243	4328	4457	4535	4610	4810	5214	5358	5381	5434	5458	5620	5725];

% req_params.cell_type = {'SNR'}; lines_snr = findLinesInDB (task_info, req_params);
% req_params.cell_type = {'PC ss','SNR'};req_params.ID = ID_cs_sig;  lines_ss = findLinesInDB (task_info, req_params);
% lines = union(lines_snr,lines_ss);


lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;  
    
    
    switch EPOCH
        case 'targetMovementOnset'
            
            rel(ii) = task_info(lines(ii)).time_sig_motion;
        case {'pursuitLatencyRMS'}
            data = getBehavior (data,supPath);
    end
    

    [effectSizes(ii,:),ts] = effectSizeInTimeBin...
        (data,EPOCH,'prevOut',false,...
        'velocityInsteadReward',false);
    
    if PLOT_CELL
        
        flds = fields(effectSizes);
        sgtitle([task_info(lines(ii)).cell_type num2str(data.info.cell_ID)])
        for f = 1:length(flds)
            
            subplot(1,length(flds),f); hold on
                        
            plot(ts,[effectSizes(ii,:).(flds{f})])
            xlabel(['time from ' raster_params.align_to ' (ms)' ])
            title(flds{f})
        end
        
        pause
        arrayfun(@cla,findall(0,'type','axes'))

    end
    
end

%%

flds = fields(effectSizes);


h = cellID<inf% & rel

figure
for f = 1:length(flds)
    
    subplot(1,length(flds),f); hold on
    
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        
        a = reshape([effectSizes(indType,:).(flds{f})],length(indType),length(ts));
        
        errorbar(ts,nanmean(a,1), nanSEM(a,1))
        xlabel(['time from ' EPOCH ' (ms)' ])
        title(flds{f}, 'Interpreter', 'none')
        
    end
    legend(req_params.cell_type)
end

%%

