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


  data = importdata(    'C:\Users\Noga\Documents\Vermis Data\pursuit_8_dir_75and25\\4569 PC ss.mat');
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
clear all

supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss';
req_params.task = 'pursuit_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 100; % ms in each side
raster_params.SD = 10; % ms in each side
timeWindow = [-50:50];

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before : raster_params.time_after;


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    match_d = match_d(~boolFail);
    PD = data.info.PD;
    raster = getRaster(data,find(~boolFail),raster_params);
    
    for t = 1:length(ts)
        runningWindow = raster_params.smoothing_margins + t + timeWindow;
        spks = sum(raster(runningWindow,:));
        
        [p,tbl,stats,terms] = anovan(spks(:),{match_d},...
            'model','interaction','display','off');
        errorTrace(ii,t) = tbl{3,5};
    end
    
end


figure;
plot(ts,mean(errorTrace))