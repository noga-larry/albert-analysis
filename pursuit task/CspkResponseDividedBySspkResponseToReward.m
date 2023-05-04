clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

PROBABILITIES =[25,75];

req_params = reqParamsEffectSize("both");

lines = findCspkSspkPairs(task_info,req_params);

raster_params.time_before = 0;
raster_params.time_after = 800;
raster_params.smoothing_margins = 100;
raster_params.SD = 20;

comparison_window = raster_params.smoothing_margins + raster_params.time_before...
    +(100:500);

ts = -raster_params.time_before:raster_params.time_after;
psths = nan(length(lines),2,length(PROBABILITIES),length(ts));

for ii = 1:length(lines)
    
    cells = findPathsToCells (supPath,task_info,[lines(1,ii),lines(2,ii)]);
    dataSspk = importdata(cells{1});
    dataCspk = importdata(cells{2});
    
    [dataSspk,dataCspk] = reduceToSharedTrials(dataSspk,dataCspk);
     
    [~,match_p] = getProbabilities (dataCspk);
    [match_o] = getOutcome (dataCspk);
    boolFail = [dataCspk.trials.fail];
    
    % SSPK comparison by reward
    raster_params.align_to = 'reward';
    
    ind = find(match_o & ~boolFail);
    raster = getRaster(dataSspk,ind,raster_params);
    spkReward = sum(raster(comparison_window,:));
    
    ind = find(~match_o & ~boolFail);
    raster = getRaster(dataSspk,ind,raster_params);
    spkNoReward = sum(raster(comparison_window,:));
    
    h(ii) = ranksum(spkNoReward,spkReward)<0.05;
    modulation(ii) = mean(spkReward) - mean(spkNoReward);
    
    % CSPK     
    
    for p = 1:length(PROBABILITIES)
        ind = find(match_o & ~boolFail & match_p==PROBABILITIES(p));
        psths(ii,1,p,:) = getPSTH(dataCspk,ind,raster_params);
        ind = find(~match_o & ~boolFail & match_p==PROBABILITIES(p));
        psths(ii,2,p,:) = getPSTH(dataCspk,ind,raster_params);
    end
end

%%
figure;

subplot(2,2,1)
ind = find(modulation>0);
plotCspk(ts,psths,ind,'SSPK increase')


subplot(2,2,2)
ind = find(modulation<0);
plotCspk(ts,psths,ind,'SSPK decrease')

subplot(2,2,3)
ind = find(modulation>0 & h);
plotCspk(ts,psths,ind,'SSPK significantly increase')

subplot(2,2,4)
ind = find(modulation<0 & h);
plotCspk(ts,psths,ind,'SSPK significantly decrease')

%% 
function plotCspk(ts,psths,ind,txt)
hold on
ave = squeeze(mean(psths(ind,1,1,:)));
sem = squeeze(nanSEM(psths(ind,1,1,:)));
errorbar(ts,ave,sem,'r')
ave = squeeze(mean(psths(ind,1,2,:)));
sem = squeeze(nanSEM(psths(ind,1,2,:)));
errorbar(ts,ave,sem,'b')

ave = squeeze(mean(psths(ind,2,1,:)));
sem = squeeze(nanSEM(psths(ind,2,1,:)));
errorbar(ts,ave,sem,'k')
ave = squeeze(mean(psths(ind,2,2,:)));
sem = squeeze(nanSEM(psths(ind,2,2,:)));
errorbar(ts,ave,sem,'g')

title(txt)

end