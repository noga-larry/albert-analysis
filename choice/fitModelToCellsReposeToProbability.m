clear all

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');


req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'choice';
req_params.ID = 5000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks =0;
req_params.remove_repeats = 0;

raster_params.align_to = 'cue';
raster_params.time_before = 0;
raster_params.time_after = 400;
raster_params.smoothing_margins = 0;
bin_sz = 50;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

PROBABILITIES  = 0:25:100;
DIRECTIONS = [0 90];

cellCounter = 0;


for ii = 1:length(cells)    
    
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    for d = 1:length(DIRECTIONS)
        
        cellCounter = cellCounter+1;        
        
        cellType{cellCounter} = task_info(lines(ii)).cell_type;
        cellID(cellCounter) = data.info.cell_ID;
        
        condCounter = 0;
        
        for j = 1:length(PROBABILITIES)
            for  k = j+1:length(PROBABILITIES)
                
                condCounter = condCounter+1;
                                
                boolProb = (match_p(1,:) == PROBABILITIES(k) & ...
                    match_p(2,:) == PROBABILITIES(j));
                
                ind = find(boolProb & ~boolFail & match_d(1,:)==DIRECTIONS(d));
                
                response(cellCounter,condCounter) = mean(getRaster(data, ind, raster_params),'all')*1000;
                
            end
        end
    end
    
end

condCounter = 0;

%%

regress_by = {'max','min','diff','ratio'};


figure; hold on

for n = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{n}, cellType));
    
    for r = 1:length(regress_by)
        
        condCounter = 0;
        for j = 1:length(PROBABILITIES)
            for  k = j+1:length(PROBABILITIES)
                condCounter = condCounter+1;
                
                switch regress_by{r}
                    case 'diff'
                        x_axis(condCounter) = PROBABILITIES(k)-PROBABILITIES(j);
                    case 'ratio'
                        x_axis(condCounter) = PROBABILITIES(k).\PROBABILITIES(j);
                    case 'min'
                        x_axis(condCounter) = min([PROBABILITIES(k),PROBABILITIES(j)]);
                    case 'max'
                        x_axis(condCounter) = max([PROBABILITIES(k),PROBABILITIES(j)]);
                end
            end
        end
        
        r_squared = nan(1,length(indType));
        
        for ii = 1:length(indType)
            
            mdl = fitlm(x_axis,response(indType(ii),:));
            r_squared(ii) = mdl.Rsquared.Adjusted;
            
        end
        
        subplot(length(req_params.cell_type),1,n); hold on
        plotHistForFC(r_squared,linspace(-0.2,1,50));
        title(req_params.cell_type(n))
    end
    
    legend(regress_by)
    xlabel('R adjusted')
end


