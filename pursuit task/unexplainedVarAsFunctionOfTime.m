%% eaxmple cells
figure;
raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD =10;
raster_params.align_to = 'targetMovementOnset';
ts = -raster_params.time_before : raster_params.time_after;
angleAroundPD = [0,180];
col = {'m','c'};


data = importdata(    'C:\Users\noga.larry\Documents\Vermis Data\pursuit_8_dir_75and25\4569 PC ss.mat');
%data = importdata( 'C:\Users\Noga\Documents\Vermis Data\pursuit_8_dir_75and25\\4806 CRB.mat');


PD = data.info.PD;
[~,match_d] = getDirections(data);
boolFail = [data.trials.fail];

for d=1:length(angleAroundPD)
    inxD = find(match_d == mod(PD+angleAroundPD(d),360) & ~boolFail);
    raster = getRaster(data,inxD,raster_params);
    psths = raster2STpsth(raster,raster_params);
    
    plot(ts,psths,col{d}); hold on
    plot(ts,mean(psths),'k','LineWidth',2)
end
  

%% population
clear 

[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'PC cs', 'CRB','SNR','BG msn'};
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';
req_params.ID = 4000:6000;
req_params.num_trials = 100;

raster_params.align_to = 'cue';
raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 0; % ms in each side

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

WINDOW_SIZE = 50;
NUM_COMPARISONS = 1;

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    boolFail = [data.trials.fail];
    ind = find(~boolFail);
    
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    
    [~,match_p] = getProbabilities (data,ind,'omitNonIndexed',true);
    raster = getRaster(data,ind,raster_params);
    
    func = @(raster) mean_var(raster,match_p);
    returnTrace(ii,:) = ...
        runningWindowFunction(raster,func,WINDOW_SIZE,NUM_COMPARISONS);
    
end

%%
ts = -(raster_params.time_before - ceil(WINDOW_SIZE/2)): ...
    (raster_params.time_after- ceil(WINDOW_SIZE/2));
figure;
for j=1:NUM_COMPARISONS
    subplot(NUM_COMPARISONS,1,j); hold on
for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    plot(ts,squeeze(mean(returnTrace(indType,:,j),1)),'*')
end
xlabel('Time from cue')
ylabel('Frac significiant')


legend(req_params.cell_type)
end

%%
function s = mean_var(raster,match)

groups = unique(match);
s = 0;
for i =1: length(groups)
    inx = find(match==groups(i));
    s = s+var(mean(raster(:,inx))*1000);
end
s = s/length(groups);
end