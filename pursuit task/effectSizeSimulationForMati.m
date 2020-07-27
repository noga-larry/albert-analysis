clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:bin_sz:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));
omegaD = nan(1,length(cells));

directions = 0:45:315;
prob = [25,75];

for ii = 1:length(cells)
    
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;

   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_d = match_d(find(~boolFail))';
    
    rasterFull = getRaster(data,find(~boolFail),raster_params);
    rasterFull = reshape(rasterFull,bin_sz,size(rasterFull,1)/bin_sz,size(rasterFull,2));
    rasterFull = (squeeze(sum(rasterFull))/bin_sz)*1000;
    
    response = nan(length(ts),sum(~boolFail));
    
    for p = 1:length(prob)
        for d = 1:length(directions)
            ind = find(match_p==prob(p) & match_d==directions(d));
            raster = rasterFull(:,ind);
            distributionAverages = mean(raster,2);
            distributionSTDs = std(raster,1,2);
            %response(:,ind) = poissrnd(repmat(distributionAverages,[1,size(raster,2)]),size(raster));
            response(:,ind) = repmat(distributionAverages,[1,size(raster,2)]) + ...
                randn(size(raster)).* repmat(distributionSTDs,[1,size(raster,2)]);
         end
    end
    
       
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','full','display','off');
    
    totVar = tbl{10,2};
    SSe = tbl{9,2};
    msw = tbl{9,5};
    N = length(raster(:));
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(ii) = omega(tbl,4)+omega(tbl,6);
    omegaRD(ii) = omega(tbl,7)+omega(tbl,8);
    
    overAllExplained(ii) = (totVar - SSe)/totVar;
    
    % organize for mati
    omegaData(ii,1) = data.info.cell_ID;
    omegaData(ii,2) = omegaR(ii);
    omegaData(ii,3) = omegaD(ii);
    omegaData(ii,4) = omegaT(ii);
    omegaData(ii,5) = omegaRD(ii);
end


%%
figure;
boolPC = strcmp('PC ss', cellType);

subplot(3,1,1)
scatter(omegaT(boolPC),omegaR(boolPC),'filled','k'); hold on
p1 = signrank(omegaT(boolPC),omegaR(boolPC));
scatter(omegaT(~boolPC),omegaR(~boolPC),'filled','m'); 
p2 = signrank(omegaT(~boolPC),omegaR(~boolPC));
xlabel('time')
ylabel('reward+time*reward')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p_{reward} = ' num2str(p1) ', CRB: p_{reward} = ' num2str(p2)])


subplot(3,1,2)
scatter(omegaT(boolPC),omegaD(boolPC),'filled','k'); hold on
p1 = signrank(omegaT(boolPC),omegaD(boolPC));
scatter(omegaT(~boolPC),omegaD(~boolPC),'filled','m'); 
p2 = signrank(omegaT(~boolPC),omegaD(~boolPC));
xlabel('time')
ylabel(' direction+time*direcion')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p_{movement} = ' num2str(p1) ', CRB: p_{movement} = ' num2str(p2)])

subplot(3,1,3)
scatter(omegaD(boolPC),omegaR(boolPC),'filled','k'); hold on
p1 = signrank(omegaD(boolPC),omegaR(boolPC));
scatter(omegaD(~boolPC),omegaR(~boolPC),'filled','m'); 
p2 = signrank(omegaD(~boolPC),omegaR(~boolPC));
ylabel('reward+time*reward')
xlabel('direction+time*direcion')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p = ' num2str(p1) ', CRB: p = ' num2str(p2)])


 
ranksum(omegaD(boolPC),omegaD(~boolPC))
figure;
bins = -0.2:0.05:1;

subplot(3,1,1)
p = ranksum(omegaD(boolPC),omegaD(~boolPC))
plotHistForFC(omegaD(boolPC),bins,'g'); hold on
plotHistForFC(omegaD(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Direction: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])

subplot(3,1,2)
p = ranksum(omegaT(boolPC),omegaT(~boolPC))
plotHistForFC(omegaT(boolPC),bins,'g'); hold on
plotHistForFC(omegaT(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Time: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])

bins = -0.2:0.01:1;

subplot(3,1,3)
p = ranksum(omegaR(boolPC),omegaR(~boolPC))
plotHistForFC(omegaR(boolPC),bins,'g'); hold on
plotHistForFC(omegaR(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Time: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])

figure;
bins = -0.3:0.05:1;

overallExplained = omegaR+omegaD+omegaT;
p = ranksum(overallExplained(boolPC),overallExplained(~boolPC))
plotHistForFC(overallExplained(boolPC),bins,'g'); hold on
plotHistForFC(overallExplained(~boolPC),bins,'r'); hold on
legend('SS', 'CRB')
title(['Over all: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(boolPC)) ', n_{crb} = ' num2str(sum(~boolPC))])


