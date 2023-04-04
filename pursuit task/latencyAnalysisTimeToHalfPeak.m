
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECIONS = [0:45:315];
PLOT_CELL = false;
req_params = reqParamsEffectSize("saccade");


raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.align_to = EPOCH;
raster_params.SD = 20;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

latency = nan(length(cells),length(DIRECIONS));

for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    boolFail = [data.trials.fail];
    [~,match_d] = getDirections(data);

    for d=1:length(DIRECIONS)
        inx = find(match_d==DIRECIONS(d) & ~boolFail);

        psth = getPSTH(data,inx,raster_params);
        baselineRate = mean(psth(1:(raster_params.time_before)));
        response = psth((raster_params.time_before):end);
        if mean(response)>baselineRate
            [peakRate,inxPeak] = max(psth((raster_params.time_before):end));
            inxPeak = raster_params.time_before + inxPeak-1;
            halfPeakThreshold = baselineRate + (peakRate - baselineRate)/2;
            lat = find(response>halfPeakThreshold,1)-1;
        else
            [peakRate,inxPeak] = min(psth((raster_params.time_before):end));
            inxPeak = raster_params.time_before + inxPeak -1;
            halfPeakThreshold = baselineRate+(peakRate - baselineRate)/2;
            lat = find(response<halfPeakThreshold,1)-1;
        end
        
        if isempty(lat)
            disp('Latency not found')
           continue
        end
        latency(ii,d) = lat;

        if PLOT_CELL
            plot(psth); hold on
            plot(inxPeak,psth(inxPeak),'*')
            xline(raster_params.time_before)
            xline(raster_params.time_before+lat)
            yline(halfPeakThreshold)
            pause
            cla
        end
    end

end

%%

figure; hold on

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    plotHistForFC([latency(indType,:)],0:10:800)
end

legend(req_params.cell_type)
xlabel('Latency')
ylabel('Frac cells')
