clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR', 'BG msn'};
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;

ts = -raster_params.time_before:raster_params.time_after;

req_params.num_trials = 50;
req_params.task = 'choice';
lines_choice = findLinesInDB (task_info, req_params);

req_params.num_trials = 100;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);

lines = findSameNeuronInTwoLineLists(task_info,lines_choice,lines_single)

accuracy = nan(2,length(lines));

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    both_cells{1} = importdata(cells{1}); both_cells{2} = importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;
    
    for d = 1:length(both_cells)
        
        data = both_cells{d};
        
        
        if strcmp(data.info.task,'choice')
            boolFail = [data.trials.fail] | ~[data.trials.choice];
            screen_rotation_choice = data.trials(1).screen_rotation;

        else
            directions = ...
                mod(screen_rotation_choice + [0, 90] +...
                data.trials(1).screen_rotation,360);
            [~,match_d] = getDirections (data);            
            boolFail = [data.trials.fail] |...
                ~(match_d==directions(1) | match_d==directions(2)) ;
        end
        

        
        ind = find(~boolFail);
        [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
        [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
        [match_o] = getOutcome(data,ind,'omitNonIndexed',true);
        [match_po] = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
        
        labels = match_d(1,:);
        raster = getRaster(data,ind,raster_params);
        N = size(raster,2);
        
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        
        accuracy(d,ii) = trainAndTestClassifier...
            ('PsthDistance',raster,labels,cross_val_sets);
    end
end


%%
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    subplot(2,ceil(length(req_params.cell_type)/2),i)
    scatter(accuracy(1,indType),accuracy(2,indType))
    p = signrank(accuracy(1,indType)',accuracy(2,indType)');
    
    title([req_params.cell_type{i} ' p = ' num2str(p)])
    ylabel('pursuit/saccade')
    xlabel('choice')
    axis([0 1 0 1])
    refline(1,0)

end


%%
f = figure;

chance_level = 1/length(unique(labels));

bins = linspace(0,1,50);
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(accuracy(2,indType),bins); hold on
    p = signrank(accuracy(2,indType)-chance_level);
    disp([req_params.cell_type{i} ': ' num2str(p)])
end
legend(req_params.cell_type)
xlabel('Accuracy')

p = kruskalwallis(accuracy(2,:),cellType);

sgtitle(f,['kruskal wallis: p = ' num2str(p)])


%%
clear
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

K_FOLD = 10;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR', 'BG msn'};
% req_params.ID = [4135, 4208, 4209, 4343, 4390, 4569,...
%     4570,4602, 4604, 4605, 4623, 4625, 4658, 4701,...
%     4791, 4806, 4821, 4846, 4886];
req_params.remove_question_marks = 1;
req_params.remove_repeats = false;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 200;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

bin_sz = 200;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

req_params.num_trials = 50;
req_params.task = 'choice';
lines_choice = findLinesInDB (task_info, req_params);

req_params.num_trials = 100;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
lines_single = findLinesInDB (task_info, req_params);

lines = findSameNeuronInTwoLineLists(task_info,lines_choice,lines_single)

accuracy = nan(2,length(ts)-1,length(lines));

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(ii).line1, lines(ii).line2]);
    both_cells{1} = importdata(cells{1}); both_cells{2} = importdata(cells{2});
    
    cellType{ii} = lines(ii).cell_type;
    cellID(ii) = lines(ii).cell_ID;
    
    for d = 1:length(both_cells)
        
        data = both_cells{d};        
        
        if strcmp(data.info.task,'choice')
            boolFail = [data.trials.fail] | ~[data.trials.choice];
            screen_rotation_choice = data.trials(1).screen_rotation;

        else
            directions = ...
                mod(screen_rotation_choice + [0, 90] +...
                data.trials(1).screen_rotation,360);
            [~,match_d] = getDirections (data);            
            boolFail = [data.trials.fail] |...
                ~(match_d==directions(1) | match_d==directions(2)) ;
        end
        
        ind = find(~boolFail);
        [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
        [~,match_d] = getDirections (data,ind,'omitNonIndexed',true);
        [match_o] = getOutcome(data,ind,'omitNonIndexed',true);
        [match_po] = getPreviousOutcomes(data,ind,'omitNonIndexed',true);
        
        labels = match_d(1,:);
        
        raster = getRaster(data,ind,raster_params);
        N = size(raster,2);
        
        cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
        
        for t=1:length(ts)-1
            
            tb = raster_params.time_before +ts(t)+1;
            te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
            w = tb:te;
            partial_raster = raster(w,:);
            
            accuracy(d,t,ii) = trainAndTestClassifier...
                ('PsthDistance',partial_raster,labels,cross_val_sets);
        end
    end
end


%%

figure;

col = {'b','y','m','g'}
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    ave = squeeze(nanmean(accuracy(2,:,indType),3));
    sem = squeeze(nanSEM(accuracy(2,:,indType),3));
    errorbar(ts(1:end-1),ave,sem,col{i}); hold on
    
end
legend(req_params.cell_type)
xlabel(['Time from ' raster_params.align_to ])
ylabel('Accuracy')
