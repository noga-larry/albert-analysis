clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Golda');

req_params.grade = 7;
req_params.cell_type = 'PC|CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

raster_params.align_to = 'targetMovementOnset';
raster_params.cue_time = 500;
raster_params.time_before = 299;
raster_params.time_after = 500;
raster_params.smoothing_margins = 0;
bin_sz = 50;

ts = -raster_params.time_before:raster_params.time_after;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

omegaT = nan(1,length(cells));
omegaR = nan(1,length(cells));
omegaD = nan(1,length(cells));

for ii = 1:length(cells)
    
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;

   
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_p = match_p(find(~boolFail))';
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    match_d = match_d(find(~boolFail))';
    
    raster = getRaster(data,find(~boolFail),raster_params);
    response = reshape(raster,bin_sz,size(raster,1)/bin_sz,size(raster,2));
    response = (squeeze(sum(response))/bin_sz)*1000;
    
    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);

    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{9,2};
    msw = tbl{8,5};
       N = length(response(:));
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(tbl{dim,2}+(N-tbl{dim,3})*msw);
      
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(ii) = omega(tbl,2);
    omegaR(ii) = omega(tbl,3)+omega(tbl,5);
    omegaD(ii) = omega(tbl,4)+omega(tbl,6);
    
    data.effect_sizes.movement.direction = omegaD(ii);
    data.effect_sizes.movement.reward = omegaR(ii);
    data.effect_sizes.movement.time = omegaT(ii);
    
    save(cells{ii},'data')
    
end


%%


figure;
subplot(3,1,1)
scatter(omegaT,omegaR,'filled'); 
p = signrank(omegaT,omegaR);
xlabel('time')
ylabel('reward+time*reward')
refline(1,0)
title(['p_{reward} = ' num2str(p)])

subplot(3,1,2)
scatter(omegaT,omegaD,'filled'); 
p = signrank(omegaT,omegaD);
title(['p_{movement} = ' num2str(p)])
xlabel('$\eta^2$ time','interpreter','latex')
ylabel('direction+time*direcion')
 refline(1,0)


subplot(3,1,3)
scatter(omegaR,omegaD,'filled'); 
p = signrank(omegaR,omegaD)
title(['p = ' num2str(p)])
xlabel('reward+time*reward')
ylabel('direction+time*direcion')
 refline(1,0)


figure;

bins = -0.1:0.02:1;
plotHistForFC(omegaT,bins,'g'); hold on
plotHistForFC(omegaR,bins,'r'); hold on
plotHistForFC(omegaD,bins,'b'); hold on
legend('T','R','D')

%%
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
title(['PC ss: p_{reward} = ' num2str(p1) ', PC ss: p_{reward} = ' num2str(p2)])


subplot(3,1,2)
scatter(omegaT(boolPC),omegaD(boolPC),'filled','k'); hold on
p1 = signrank(omegaT(boolPC),omegaD(boolPC));
scatter(omegaT(~boolPC),omegaD(~boolPC),'filled','m'); 
p2 = signrank(omegaT(~boolPC),omegaD(~boolPC));
xlabel('time')
ylabel(' direction+time*direcion')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p_{movement} = ' num2str(p1) ', PC ss: p_{movement} = ' num2str(p2)])

subplot(3,1,3)
scatter(omegaR(boolPC),omegaD(boolPC),'filled','k'); hold on
p1 = signrank(omegaR(boolPC),omegaD(boolPC));
scatter(omegaR(~boolPC),omegaD(~boolPC),'filled','m'); 
p2 = signrank(omegaR(~boolPC),omegaD(~boolPC));
xlabel('reward+time*reward')
ylabel('direction+time*direcion')
refline(1,0)
legend('PC ss','CRB')
title(['PC ss: p = ' num2str(p1) ', PC ss: p = ' num2str(p2)])

subplot(3,2,5)
ind = find(boolPC);
scatter(omegaR(ind),omegaD(ind),'filled'); 
p = signrank(omegaR(ind),omegaD(ind))
title(['PC ss: p = ' num2str(p)])
xlabel('reward+time*reward')
ylabel('direction+time*direcion')
 refline(1,0)
 
 
 ind = find(~boolPC);
subplot(3,2,2)
scatter(omegaT(ind),omegaR(ind),'filled'); 
p = signrank(omegaT(ind),omegaR(ind));
xlabel('time')
ylabel('reward+time*reward')
refline(1,0)
title(['CRB: p_{reward} = ' num2str(p)])

subplot(3,2,4)
scatter(omegaT(ind),omegaD(ind),'filled'); 
p = signrank(omegaT(ind),omegaD(ind));
title(['CRB: p_{movement} = ' num2str(p)])
xlabel('time','interpreter','latex')
ylabel(' direction+time*direcion')
 refline(1,0)


subplot(3,2,6)
scatter(omegaR(ind),omegaD(ind),'filled'); 
p = signrank(omegaR(ind),omegaD(ind))
title(['CRB: p = ' num2str(p)])
xlabel('reward+time*reward')
ylabel('direction+time*direcion')
 refline(1,0)
 
 
 
 
ranksum(omegaD(boolPC),omegaD(~boolPC))

% plot(ones(length(cells),1),omegaT,'or'); hold on
% errorbar(1,mean(omegaT),std(omegaT)/sqrt(length(cells)),'ko','MarkerSize',8,'MarkerFaceColor','k'); hold on
% plot(2*ones(length(cells),1),omegaR,'ob'); hold on
% errorbar(2,mean(omegaR),std(omegaR)/sqrt(length(cells)),'ko','MarkerSize',8,'MarkerFaceColor','k'); hold on
% plot(3*ones(length(cells),1),omegaD,'og'); hold on
% errorbar(3,mean(omegaD),std(omegaD)/sqrt(length(cells)),'ko','MarkerSize',8,'MarkerFaceColor','k'); hold on


% legend ('T','aveT','R','aveR','D','aveD')
