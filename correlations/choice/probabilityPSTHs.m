clear

[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

angles = [0,90];
probabilities = [0:25:100];
test_window_form_event = 1:300;
NUM_COND = 10;

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 100;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

raster_params.time_before = 399;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 10;
raster_params.align_to = 'targetMovementOnset';

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

ts = -raster_params.time_before:raster_params.time_after;
test_window_in_raster = raster_params.smoothing_margins+...
    raster_params.time_before + test_window_form_event;
% 0 - nonsignificant, 1-higher for 0, -1 - higher for 90
respose_significance = nan(length(cells),1);
psths = nan(length(cells),length(angles),NUM_COND...
    ,length(ts));
for ii=1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    [match_o] = getOutcome (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    ind = find(~boolFail);
    raster = getRaster(data,ind,raster_params);
    baseline = mean(raster2psth(raster,raster_params));
    
    for d = 1:length(angles)
        
        boolDir = match_d(1,:)== angles(d);
        ind = find(~boolFail & boolDir);
        raster = getRaster(data,ind,raster_params);
        
        spks{d} = sum(raster(test_window_in_raster,:));
        
        prob_counter = 0;
        for j = 1:length(probabilities)
            for  k = j+1:length(probabilities)
                
                prob_counter = prob_counter +1;
                boolProb = (match_p(1,:) == probabilities(k) & ...
                    match_p(2,:) == probabilities(j));
                ind = find (boolProb & (~boolFail) & boolDir);
                raster = getRaster(data,ind,raster_params);
                
                psths(ii,d,prob_counter,:) = raster2psth(raster,raster_params)...
                    -baseline;
                
                leg{prob_counter} = [num2str(probabilities(j)) ...
                    ' vs ' num2str(probabilities(k))];
            end
        end
    end
    
    PD(ii) = angles(heaviside(mean(spks{2})-mean(spks{1}))+1);
    respose_significance(ii) = ranksum(spks{1},spks{2})<0.05;
    
    data.info.PD = PD(ii); 
    
    save(cells{ii},'data')
    
end

%%
figure; hold on
col = varycolor(NUM_COND);
v = unique(respose_significance);
for d = 1:length(angles)
    for i = 1:length(v)
        subplot(length(angles),length(v),...
            length(v)*(d-1)+i); hold on
        ind = find(respose_significance==v(i));
        for p=1:NUM_COND
            
            ave_psths = squeeze(mean(psths(ind,d,p,:),1));
            plot(ts,ave_psths,'Color',col(p,:))
        end
        xlabel(['Time from ' raster_params.align_to ' (ms)'])
        ylabel('FR')
        switch v(i)
            case 0
                t = 'non significant';
            case 1
                t = '0 is larger';
            case -1
                t = '90 is larger';
        end
        title([t ': ' num2str(angles(d)) ', n = ' num2str(length(ind))])
    end
end
legend(leg)

%sgtitle(['Golda, ' req_params.cell_type])

%% average over directon
figure; hold on
col = varycolor(NUM_COND);

psths_aligned = nan(size(psths));

for ii = 1:size(psths,1)
    
    switch PD(ii)

        case 0
            psths_aligned(ii,1,:,:) = squeeze(psths(ii,1,:,:));
            psths_aligned(ii,2,:,:) = squeeze(psths(ii,2,:,:));
        case 90
            psths_aligned(ii,1,:,:) = squeeze(psths(ii,2,:,:));
            psths_aligned(ii,2,:,:) = squeeze(psths(ii,1,:,:));
    end
end

ave_psths = squeeze(nanmean(psths_aligned,1));

for d = 1:size(ave_psths,1)
    subplot(size(ave_psths,1),1,d); hold on
    for p=1:NUM_COND
        plot(ts,squeeze(ave_psths(d,p,:)),'Color',col(p,:))
    end
end



xlabel(['Time from ' raster_params.align_to ' (ms)'])
ylabel('FR')
legend(leg)
sgtitle(['n = ' num2str(size(psths_aligned,1))])