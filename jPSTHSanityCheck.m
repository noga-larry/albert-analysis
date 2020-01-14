raster_params.allign_to = 'cue';
raster_params.cue_time = 500;
raster_params.time_before = 300;
raster_params.time_after = 700;
raster_params.smoothing_margins = 0;
raster_params.bin_size = 10;
raster_params.plot_cell = 1;


%% cells that are simple random noise


for t = 1:length(data1.trials)
    
data1.trials(t).spike_times = data1.trials(t).trial_length*rand(1,length(data1.trials(t).spike_times));
data2.trials(t).spike_times = data1.trials(t).trial_length*rand(1,length(data2.trials(t).spike_times));

end

    [jPSTHraw,jPSTHprod] = jPSTH(data1,data2,1:length(data1.trials),raster_params)
