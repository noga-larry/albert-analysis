data = importdata('C:\Users\Noga\Documents\Vermis Data\saccade_8_dir_75and25\\4243 PC ss.mat')

data = importdata('C:\Users\Noga\Documents\Vermis Data\saccade_8_dir_75and25\\4814 CRB.mat')

figure;
raster_params.time_before = -399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
raster_params.align_to = 'targetMovementOnset';

angles = [0 180];
PD = data.info.PD;
col = {'c','g'};
ts = -raster_params.time_before:raster_params.time_after;


for d=1:length(angles)
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
    raster = getRaster(data,inx, raster_params);
    psth = raster2STpsth(raster,raster_params);
    
    plot(ts, psth,col{d}); hold on
    plot(ts,mean(psth),'k','LineWidth',2)
    
    
    
end

%% Histograms

data = importdata('C:\Users\Noga\Documents\Vermis Data\saccade_8_dir_75and25\\4243 PC ss.mat')

%data = importdata('C:\Users\Noga\Documents\Vermis Data\saccade_8_dir_75and25\\4814 CRB.mat')

figure;
raster_params.time_before = 1;
raster_params.time_after = 700;
raster_params.smoothing_margins = 100;
raster_params.align_to = 'targetMovementOnset';

angles = [0 180];
PD = data.info.PD;
col = {'c','g'};
ts = -raster_params.time_before:raster_params.time_after;


for d=1:length(angles)
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail];
    inx = find ((match_d == mod(PD+angles(d),360) | match_d == mod(PD-angles(d),360)) & (~boolFail));
    raster = getRaster(data,inx, raster_params);
    
    spks = mean(raster)*1000;
    plotHistForFC(spks,8,col{d}); hold on
    
    
    
end


%%
data = importdata('C:\Users\Noga\Documents\Vermis Data\saccade_8_dir_75and25\\4351 CRB.mat')

raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 100;
bin_sz = 50;

[~,match_d] = getDirections(data);
boolFail = [data.trials.fail];
angles = [0:45:315];
ts = -raster_params.time_before:raster_params.time_after;
colors = varycolor(length(angles));

for d = 1:length(angles)
    
    inx = find (match_d == angles(d) & ~boolFail );
    
    raster = getRaster(data,inx, raster_params);
    psth = raster2psth(raster,raster_params);
    plot(ts,psth,'Color',colors(d,:)); hold on
    
end
%% Rasters

figure;
raster_params.time_before = 399;
raster_params.time_after = 1200;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
raster_params.align_to = 'targetMovementOnset';

directions = 0:45:315;
probabilities = [25, 75];

for p=1:length(probabilities)
    for d=1:length(directions)
        [~,match_d] = getDirections(data);
        [~,match_p] = getProbabilities(data);
        boolFail = [data.trials.fail];
        inx = find (match_d == directions(d) & match_p == probabilities(p) & (~boolFail));
        raster = getRaster(data,inx, raster_params);
        
        subplot(length(probabilities),length(directions),(length(directions)*(p-1)+d))
        plotRaster(raster,raster_params)
        title(['p = ' num2str(probabilities(p)) ', d = ' num2str(directions(d)) ])
    end
    
end
 suptitle(num2str(data.info.cell_ID))