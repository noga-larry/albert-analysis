
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

EPOCH = 'targetMovementOnset';
DIRECIONS = 0:45:315;
PROBABILITIES = [25,75];
PLOT_CELL = false;
TASK = "saccade";
req_params = reqParamsEffectSize(TASK);
%req_params.cell_type = {'BG msn'};

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.align_to = EPOCH;
raster_params.SD = 20;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

cellType = cell(length(cells),1);
cellID = nan(length(cells),1);

switch EPOCH
    case 'targetMovementOnset'
        latency = nan(length(cells),length(PROBABILITIES),length(DIRECIONS));
end


for ii = 1:length(cells)

    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    boolFail = [data.trials.fail];
    [~,match_d] = getDirections(data);
    [~,match_p] = getProbabilities(data);
    
    switch EPOCH
        
        case 'targetMovementOnset'
            for p=1:length(PROBABILITIES)
                for d=1:length(DIRECIONS)
                    inx{d} = find(match_p==PROBABILITIES(p) & ...
                        match_d==DIRECIONS(d) & ~boolFail);
                end
                for j=1:length(inx)
                    latency(ii,p,j) = rateChange(data,inx,j,raster_params,PLOT_CELL);
                end
            end
            
    end
    
    effects(ii) = effectSizeInEpoch(data,EPOCH);
    



end

%%

figure; hold on

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    plotHistForFC([latency(indType,:,:)],0:5:800)

    leg{i} = [req_params.cell_type{i} ' - frac latency found: ' num2str(mean(~isnan([latency(indType,:)]),"all"))];
end

legend(leg)
xlabel('Latency')
ylabel('Frac cells')
sgtitle(TASK)

figure; hold on

[~,edges] = discretize([effects.directions],5);

for i = 1:length(req_params.cell_type)
    indType = find(strcmp(req_params.cell_type{i}, cellType));

    for j=1:length(edges)-1
        inx = intersect(indType,  find([effects.directions]>=edges(j) &...
            [effects.directions]<edges(j+1)));

        ave_effect(j) = mean([effects(inx).directions]);
        x=latency(inx,:);

        ave_latency(j) = mean(x(:),'all','omitnan');
        sem_latency(j) = nanSEM(x(:));
%         ave_latency(j) = median(x(:),'all','omitnan');
%         if ~isnan(ave_latency(j))
%             ci = bootci(1000,@(x) median(x,'omitnan'),x(:));
%         else
%             ci = [nan nan];
%         end
%         pos(j) = ci(1); neg(j) = ci(2);
    end
%errorbar(ave_effect,ave_latency,neg,pos)
errorbar(ave_effect,ave_latency,sem_latency)
xlabel('mean effect size')
ylabel('median latency')
end

sgtitle(TASK)
legend(req_params.cell_type)
%%

function lat = halfPeak(data,inx,raster_params,plot_option)

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
    lat = nan;
    return
end

if plot_option
    plot(psth); hold on
    plot(inxPeak,psth(inxPeak),'*')
    xline(raster_params.time_before)
    xline(raster_params.time_before+lat)
    yline(halfPeakThreshold)
    pause
    cla
end

end

%%

function lat = rateChange(data,trailInxArray,curGroup,raster_params,plotOption)

SDThresh = 5;
TIME_BEFORE = 100;

% get baseline 

baseline_params.SD = raster_params.SD;
baseline_params.align_to = raster_params.align_to;
baseline_params.time_before = raster_params.time_before;
baseline_params.time_after = -TIME_BEFORE;
baseline_params.smoothing_margins = raster_params.smoothing_margins;

baselinePsth = [];
for i=1:length(trailInxArray)
    baselinePsth = [baselinePsth;getPSTH(data,trailInxArray{i},baseline_params)];

end

baselineSD = std(baselinePsth);
baselineAve = mean(baselinePsth);

bottomThresh = baselineAve - SDThresh*baselineSD;
upperThresh = baselineAve + SDThresh*baselineSD;

% get response

response_params.SD = raster_params.SD;
response_params.align_to = raster_params.align_to;
response_params.time_before = 0;
response_params.time_after =  raster_params.time_after;
response_params.smoothing_margins = raster_params.smoothing_margins;

response = getPSTH(data,trailInxArray{curGroup},response_params);

lat = find(response>upperThresh | response<bottomThresh,1);

if isempty(lat)
    disp('Latency not found')
    lat = nan;
    
end


if plotOption
    
    ts = -raster_params.time_before:raster_params.time_after;
    ax1= subplot(2,1,1);
    psth = getPSTH(data,trailInxArray{curGroup},raster_params);
    plot(ts,psth); hold on
    if ~isnan(lat)
        plot(ts(raster_params.time_before+lat),psth(raster_params.time_before+lat),'*')
    end
    yline(bottomThresh)
    yline(upperThresh)
    xline(0)

    ax2 = subplot(2,1,2);
    raster = getRaster(data,trailInxArray{curGroup},raster_params);
    plotRaster(raster,raster_params,'k')

    pause
    cla(ax1); cla(ax2);
end


end