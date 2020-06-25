clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 20;
req_params.remove_question_marks = 1;

raster_params.align_to = 'cue';
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;

    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{6,2};
    msw = tbl{5,5};
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,4);
    
 end

figure;
scatter(omegaT,omegaR,'filled'); 
p = signrank(omegaT,omegaR);
xlabel('time')
ylabel('reward+time*reward')
title(['p_{reward} = ' num2str(p)])
refline(1,0)
%%
figure;
boolPC = strcmp('PC ss', cellType);

scatter(omegaT(boolPC),omegaR(boolPC),'filled','k'); hold on
p1 = signrank(omegaT(boolPC),omegaR(boolPC));
scatter(omegaT(~boolPC),omegaR(~boolPC),'filled','m'); 
p2 = signrank(omegaT(~boolPC),omegaR(~boolPC));
xlabel('time')
ylabel('reward+time*reward')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p_{reward} = ' num2str(p1) ', CRB: p_{reward} = ' num2str(p2)])
 
figure;
bins = -0.2:0.05:1;

subplot(3,1,1)
p = ranksum(omegaT(boolPC),omegaT(~boolPC))
plotHistForFC(omegaT(boolPC),bins,'g'); hold on
plotHistForFC(omegaT(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Time: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])
xlabel ('Time effect size')
bins = -0.2:0.01:1;

subplot(3,1,2)
p = ranksum(omegaR(boolPC),omegaR(~boolPC))
plotHistForFC(omegaR(boolPC),bins,'g'); hold on
plotHistForFC(omegaR(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Reward: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])
xlabel ('Reward effect size')

subplot(3,1,3)
overallExplained = omegaR+omegaT;
p = ranksum(overallExplained(boolPC),overallExplained(~boolPC))
plotHistForFC(overallExplained(boolPC),bins,'g'); hold on
plotHistForFC(overallExplained(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Over all: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])
xlabel ('Total Explained')


