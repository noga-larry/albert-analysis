clear

[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Vermis');
PROBABILITIES = [25, 75];
DIRECTIONS = 0:45:315;

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 120;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 0;
raster_params.time_after = 700;
raster_params.SD = 10;
raster_params.smoothing_margins = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    
    
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    cellType{ii} = data.info.cell_type;
    cellID(ii) = data.info.cell_ID;
    
    boolFail = [data.trials.fail];
    [~,match_p] = getProbabilities (data);
    [~,match_d] = getDirections (data);
    
    for p = 1:length(PROBABILITIES)
        
        
        spikes =[];
        RTs =[];
        
        % substract RT average in direction to reduce directional variance
        for d = 1:length(DIRECTIONS)
            inx = find (match_p == PROBABILITIES(p) & (~boolFail)...
                & match_d == DIRECTIONS(d));
            
            raster = getRaster(data,inx, raster_params);
            spikes = [spikes, mean(raster)*1000];
            
            RTs_dir = saccadeRTs(data,inx);
            RTs = [RTs, RTs_dir - nanmean(RTs_dir)];
        end
        correlationHigh(p,ii) = corr(spikes',RTs','Rows','Pairwise');
    end
    
end

%%
figure; hold on
bins = -1:0.1:1;
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    plotHistForFC(squeeze(correlationHigh(1,indType)),bins);
    disp(signrank(squeeze(correlationHigh(1,indType))))
end


xlabel('High'); ylabel('Low')
