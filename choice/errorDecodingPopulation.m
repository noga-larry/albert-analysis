clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = 0:25:100;
DIRECTIONS = [0,90];
POPULATIONS = {'SNR'};

req_params.grade = 7;
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

pop_to_inx = containers.Map;

c = 1;

for j = 1:length(POPULATIONS)
    
    req_params.cell_type = POPULATIONS{j};
    lines = findLinesInDB (task_info, req_params);
    cells = findPathsToCells (supPath,task_info,lines);
    
    pop_inx = [];
    

    for ii = 1:length(cells)
        
        c = c + 1;      
        
        pop_inx = [pop_inx c];
        
        data = importdata(cells{ii});
        cellType{c} = task_info(lines(ii)).cell_type;
        cellID(c) = data.info.cell_ID;
        
        ind = find(~[data.trials.fail]);
        
        [~,pop_match_p{c}] = getProbabilities (data,ind,'omitNonIndexed',true);
        [~,pop_match_d{c}] = getDirections (data,ind,'omitNonIndexed',true);
        
        pop_choice{c} = [data.trials(ind).choice];
        
        pop_raster{c} = getRaster(data,ind,raster_params);
        
    end
    pop_to_inx(POPULATIONS{j}) = pop_inx;
end

%%

REPEATS = 70;
TEST_SET_SIZE = 10;

test_labels = [zeros(1,TEST_SET_SIZE), 90 * ones(1,TEST_SET_SIZE)]; 

for j = 1:length(POPULATIONS)
    
    num_cells = length(pop_to_inx(POPULATIONS{j}));
    
    for n = 1:num_cells
        
        for r = 1:REPEATS
            
            inx = pop_to_inx(POPULATIONS{j});
            inx = inx(randperm(length(inx),n));
            
            for t=1:length(ts)-1
                
                tb = raster_params.time_before +ts(t)+1;
                te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
                w = tb:te;
                
                c = 0;
                
                for p1=1:length(PROBABILITIES) %larger
                    for p2 = 1:(p1-1) %smaller
                        
                        c = c +1;
                        
                        for ii = 1:length(inx)
                            
                            match_p = pop_match_p{inx(ii)};
                            choice = pop_choice{inx(ii)};
                            match_d = pop_match_d{inx(ii)};
                            raster = pop_raster{inx(ii)};
                            
                            bool_prob = (match_p(1,:)== PROBABILITIES(p1))...
                                & (match_p(2,:)== PROBABILITIES(p2));
                            
                            ind_train = find(choice & ~bool_prob);
                            labels_train{ii} = match_d(1,ind_train);
                            raster_train{ii} = raster(w,ind_train);
                            
                            % assert(isempty(intersect(ind_train,ind_test)))
                            raster_test_correct{ii} = [];
                            raster_test_error{ii} = [];
                            
                            for d = DIRECTIONS
                                
                                all_inds = find(bool_prob & choice & match_d(1,:)==d);
                                
                                if isempty(all_inds)
                                    
                                    raster_test_correct{ii} = [raster_test_correct{ii}...
                                        nan(length(w),TEST_SET_SIZE)];
                                else
                                    ind_test_correct = all_inds(randi(length(all_inds),...
                                        TEST_SET_SIZE,1));
                                    
                                    raster_test_correct{ii} = [raster_test_correct{ii}...
                                        raster(w,ind_test_correct)];
                                end
                                
                                all_inds = find(bool_prob & ~choice & match_d(1,:)==d);
                                
                                if isempty(all_inds)
                                    
                                    raster_test_error{ii} = [raster_test_error{ii}...
                                        nan(length(w),TEST_SET_SIZE)];
                                else
                                    ind_test_error = all_inds(randi(length(all_inds),...
                                        TEST_SET_SIZE,1));
                                    
                                    raster_test_error{ii} = [raster_test_error{ii}...
                                        raster(w,ind_test_error)];
                                end
                            end
                        end
                        
                        mdl = classifierFactory('PopulationPsthDistance');
                        mdl = mdl.train(raster_train,labels_train);
                        accuracy_correct(c) = mdl.evaluate(raster_test_correct,test_labels);
                        accuracy_error(c) = mdl.evaluate(raster_test_error,test_labels);
                        
                    end
                end  
                ave_accuracy_correct(r,n,t) = nanmean(accuracy_correct);
                ave_accuracy_error(r,n,t) = nanmean(accuracy_error);
            end
        end

    end
end


%%
figure; hold on

ave = squeeze(nanmean(ave_accuracy_correct));
sem = squeeze(nanSEM(ave_accuracy_correct));
imagesc(ts(1:end-1),1:4,ave)




figure; hold on

ave = squeeze(nanmean(ave_accuracy_error));
sem = squeeze(nanSEM(ave_accuracy_error));
imagesc(ts(1:end-1),1:4,ave)


    
    
   


