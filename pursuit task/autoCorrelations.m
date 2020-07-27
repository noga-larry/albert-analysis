clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'CRB|PC ss';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 100;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

directions = 0:45:315;
prob = [25,75];
autoCorrelation = nan(length(cells),...
    length(ts),length(ts));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    [~,match_d] = getDirections (data);
    
    cellAutoCorrelation = nan(length(directions)*length(prob),...
        length(ts),length(ts));
    for p = 1:length(prob)
        for d = 1:length(directions)
            ind = find(~boolFail & match_p==prob(p) & match_d==directions(d));
            raster = getRaster(data,ind,raster_params);
            response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
            response = (squeeze(sum(response))/bin_sz)*1000;
            cellAutoCorrelation(length(directions)*(p-1)+d,:,:) = corr(response',response');
        end
    end
    autoCorrelation(ii,:,:) = squeeze(nanmean(cellAutoCorrelation));
    aveCorr(ii) = mean(diag(squeeze(autoCorrelation(ii,:,:)),1));
    %         figure;
    %         imagesc(squeeze(AutoCorrelation(ii,:,:)))
    %         pause
    
    
end
%%
figure;
boolPC = strcmp('PC ss', cellType);
bins = -1:0.1:1;
subplot(2,2,1)
imagesc(ts,ts,squeeze(nanmean(autoCorrelation(boolPC,:,:)))); colorbar
title('Sspks')
subplot(2,2,2)
imagesc(ts,ts,squeeze(nanmean(autoCorrelation(~boolPC,:,:)))); colorbar
title('LCN')
subplot(2,1,2)
plotHistForFC(aveCorr(boolPC),bins,'k'); hold on
plotHistForFC(aveCorr(~boolPC),bins,'m')
xlabel('correlation of t and t+1')
ylabel('fraction of cells')
legend('Sspks', 'LCN')


