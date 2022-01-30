clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = 0:25:100;

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'choice';
req_params.num_trials = 100;
req_params.remove_repeats = false;
req_params.ID = 4000:6000;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 200;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

BIN_SIZE = 100;

ts = -raster_params.time_before:BIN_SIZE:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ave_accuracy_correct = nan(length(ts)-1,length(cells));
ave_accuracy_error = nan(length(ts)-1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    bool_fail_train = [data.trials.fail] | ~[data.trials.choice];
    bool_fail_test = [data.trials.fail];
    
    [~,match_p] = getProbabilities (data);
    
    c = 0; 
    for p1=1:length(PROBABILITIES) %larger
        for p2 = 1:(p1-1) %smaller
            
            c = c +1;
            bool_prob = (match_p(1,:)== PROBABILITIES(p1))...
                & (match_p(2,:)== PROBABILITIES(p2));
            
            ind_train = find(~bool_fail_train & ~bool_prob);
            ind_test = find(~bool_fail_test & bool_prob);
            
            assert(isempty(intersect(ind_train,ind_test)))
            
            [~,match_d] = getDirections (data,ind_train,'omitNonIndexed',true);
            labels_train = match_d(1,:);
            
            [~,match_d] = getDirections (data,ind_test,'omitNonIndexed',true);
            labels_test = match_d(1,:);
            
            raster_train = getRaster(data,ind_train,raster_params);
            raster_test = getRaster(data,ind_test,raster_params);
            
            for t=1:length(ts)-1
                
                tb = raster_params.time_before +ts(t)+1;
                te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
                w = tb:te;
                
                partial_raster_train = raster_train(w,:);
                partial_raster_test = raster_test(w,:);
                
                mdl = classifierFactory('PsthDistance');
                mdl = mdl.train(partial_raster_train,labels_train);
                
                choice = [data.trials(ind_test).choice];
                
                accuracy_correct(c,t) = mdl.evaluate(partial_raster_test(:,choice),...
                    labels_test(choice));
                accuracy_error(c,t) = mdl.evaluate(partial_raster_test(:,~choice)...
                    ,labels_test(~choice));
                
            end
        end
    end
    ave_accuracy_correct(:,ii) = nanmean(accuracy_correct);
    ave_accuracy_error(:,ii) = nanmean(accuracy_error);
end

%%
figure;

ind = find(cellID>0);
for i = 1:length(req_params.cell_type)
    
    subplot(2,ceil(length(req_params.cell_type)/2),i); hold on
    indType = intersect(ind,...
        find(strcmp(req_params.cell_type{i}, cellType)));
    ave = nanmean(ave_accuracy_correct(:,indType),2);
    sem = nanSEM(ave_accuracy_correct(:,indType),2);
    errorbar(ts(1:end-1),ave,sem)
    
    ave = nanmean(ave_accuracy_error(:,indType),2);
    sem = nanSEM(ave_accuracy_error(:,indType),2);
    errorbar(ts(1:end-1),ave,sem)
    
    title(req_params.cell_type{i})
    xlabel(['Time from ' raster_params.align_to ])
    ylabel('Accuracy')
    ylim([0 1])
    yline(0.5)
end
legend(req_params.cell_type)



