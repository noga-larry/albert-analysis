clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');
load('sessionMap.mat')

K_FOLD = 10;
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.num_trials = 80;
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(1,length(cells));

%% 90 dgrees apart

for ii = 1:length(lines)
    
    data = importdata(cells{ii});
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
        
    
    [~,match_d] = getDirections (data);
    
    for d = 1:length(DIRECTIONS)
        
        cur_directions = ...
            mod(DIRECTIONS(d) + [0, 90],360);
        
        boolFail = [data.trials.fail] |...
            ~(match_d==cur_directions(1) | match_d==cur_directions(2)) ;
        
        ind = find(~boolFail);
        [~,match_d_cur] = getDirections (data,ind,'omitNonIndexed',true);
                
        labels = match_d_cur(1,:);
        raster = getRaster(data,ind,raster_params);
        N = size(raster,2);
        
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        
        accuracy_per_dir(d) = trainAndTestClassifier...
            ('PsthDistance',raster,labels,cross_val_sets);
    end
    
    accuracy(ii) = mean(accuracy_per_dir);
    
end

%% all combinations
for ii = 1:length(lines)
    
    data = importdata(cells{ii});
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
        
    
    [~,match_d] = getDirections (data);
    counter =1;
    for d1 = 1:length(DIRECTIONS)
        
        for d2 = d1+1:length(DIRECTIONS)
            
            cur_directions = [DIRECTIONS(d1) DIRECTIONS(d2)];
            
            
            boolFail = [data.trials.fail] |...
                ~(match_d==cur_directions(1) | match_d==cur_directions(2)) ;
            
            ind = find(~boolFail);
            [~,match_d_cur] = getDirections (data,ind,'omitNonIndexed',true);
            
            labels = match_d_cur(1,:);
            raster = getRaster(data,ind,raster_params);
            N = size(raster,2);
            
            cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
            
            accuracy_per_dir(counter) = trainAndTestClassifier(...
                'PsthDistance',raster,labels,cross_val_sets);
            
            counter = counter+1;
        end
    end
    
    accuracy(ii) = mean(accuracy_per_dir);
    
end
%%
figure;

bins = linspace(0,1,50);
ind_relevant = 1:length(cells)
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(accuracy(intersect(ind_relevant,indType)),bins); hold on
    p = signrank(accuracy(intersect(ind_relevant,indType))-(1/8));
    disp([req_params.cell_type{i} ': ' num2str(p)])
end
legend(req_params.cell_type)
sgtitle(num2str(nanmean(accuracy)),'Interpreter', 'none');
xlabel('Accuracy')

kruskalwallis(accuracy,cellType)