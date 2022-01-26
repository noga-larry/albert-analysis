
clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES = 0:25:100; 

req_params.grade = 7;
req_params.cell_type = {'PC ss','PC cs', 'CRB','SNR', 'BG msn'};
req_params.task = 'choice';
req_params.num_trials = 150;
req_params.remove_question_marks = 0;
req_params.remove_repeats = false;
req_params.ID = 4000:6000;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 200;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 300;

bin_sz = 200;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

accuracy = nan(length(ts)-1,length(cells));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [~,match_p] = getProbabilities (data);

    for p1=1:length(PROBABILITIES)%larger
       for p2=1:(p1-1)%smaller
           
           boolFail = [data.trials.fail] | ~[data.trials.choice];
           ind_training = find(~boolFail &...
               (~(match_p(1,:)==PROBABILITIES(p1)) |...
               ~(match_p(2,:)==PROBABILITIES(p2))));
           
           boolFail = [data.trials.fail];
           ind_test = find(~boolFail &...
               (match_p(1,:)==PROBABILITIES(p1)) &...
               (match_p(2,:)==PROBABILITIES(p2)));
           
           assert(isempty(intersect(ind_training,ind_test)))
       end
    end
        
    labels = match_d(1,:);
    
    raster = getRaster(data,ind,raster_params);
    N = size(raster,2);     
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    for t=1:length(ts)-1
        
        tb = raster_params.time_before +ts(t)+1;
        te = raster_params.time_before + 2*raster_params.smoothing_margins+ts(t+1);
        w = tb:te;
        partial_raster = raster(w,:);        
        
        accuracy(t,ii) = trainAndTestClassifier...
            ('PsthDistance',partial_raster,labels,cross_val_sets);        
    end
end