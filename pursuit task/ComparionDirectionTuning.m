% Probability Tuning curves
supPath = 'C:\noga\TD complex spike analysis\Data\albert\pursuit_8_dir_75and25';
load ('C:\noga\TD complex spike analysis\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;


raster_params.allign_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = -100;
raster_params.time_after = 300;
raster_params.smoothing_margins = 0;
raster_params.SD = 10;
req_params.remove_question_marks = 1;

ts = -raster_params.time_before:raster_params.time_after;
directions = 0:45:315;
cells = findPathsToCells (supPath,task_info,req_params);

etaSquaredCRB = nan(1,length(cells));

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
 
    [~,match_d] = getDirections(data);
    inx = find (~boolFail);
    raster = getRaster(data,inx,raster_params);
    spikes = sum(raster,1);
    SST = sum(spikes-mean(spikes).^2);
    
    directionMeans = nan(1,length(directions));
    for d=1:length(directions)
        inx = find (match_d == directions(d) & (~boolFail));
        raster = getRaster(data,inx,raster_params);
        spikes = sum(raster,1);
        directionMeans(d) = mean(spikes);
    end
    SSB = sum(directionMeans-mean(directionMeans).^2);
    
    etaSquaredCRB(ii) = SSB/SST;
    
    
    
end

req_params.cell_type = 'PC ss';
cells = findPathsToCells (supPath,task_info,req_params);
etaSquaredSspk = nan(1,length(cells));

for ii = 1:length(cells)
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
 
    [~,match_d] = getDirections(data);
    inx = find (~boolFail);
    raster = getRaster(data,inx,raster_params);
    spikes = sum(raster,1);
    SST = sum(spikes-mean(spikes).^2);
    
    directionMeans = nan(1,length(directions));
    for d=1:length(directions)
        inx = find (match_d == directions(d) & (~boolFail));
        raster = getRaster(data,inx,raster_params);
        spikes = sum(raster,1);
        directionMeans(d) = mean(spikes);
    end
    SSB = sum(directionMeans-mean(directionMeans).^2);
    
    etaSquaredSspk(ii) = SSB/SST;
    
    
    
end


%% 
figure;
intervals = 0.05;
[counts,centers] = hist(etaSquaredSspk,0:intervals:1);
plot(centers, counts/length(etaSquaredSspk)); hold on
[counts,centers] = hist(etaSquaredCRB,0:intervals:1);
plot(centers, counts/length(etaSquaredCRB)); hold on
legend ('Simple spikes','CRBs')
xlabel('Eta Squared of direction')
ylabel('Fraction of cells')
p = ranksum(etaSquaredSspk,etaSquaredCRB)
