clear

statistic_func = @func;

%statistic_func = @(smpl)  var(reshape(squeeze(mean(smpl)),1,[]));

T = 10;
N_TRIAL = 25; %average per condition
base_vals(:,1) = linspace(0,1,T);
base_vals(:,2) = linspace(0,-1,T); 
var_vals = [0:20];
permDims = {[2],[3]};
varNames =  {'reward'}; 


for v = 1:length(var_vals)

var_fact = var_vals(v);

match = [ones(N_TRIAL+randi([-2,2]),1);2*ones(N_TRIAL+randi([-2,2]),1)];

rand_val = [randn([length(match), T])] *sqrt(var_fact);

response = nan(length(match),T);
response(1:sum(match==1),:) = bsxfun(@plus, rand_val(match==1,:), base_vals(:,1)');
response(sum(match==1)+1:end,:) = bsxfun(@plus, rand_val(match==2,:), base_vals(:,2)');


tmp_var = var(response, [],1);
real_var = mean(tmp_var(:));
 
statDist = permVarFrac(response,match,statistic_func,...
    'plotCell',true,'varNames',varNames);

totMean = mean(response(:));
SStot = sum((response(:) - totMean).^2);
SStime =  sum((mean(response,[1,3]) - totMean).^2);
SSreward =  sum((mean(response,[1,2]) - totMean).^2);
SSerror = bsxfun(@minus,permute(response,[2,3,1]),squeeze(mean(response,1)));
SSerror = sum(SSerror(:).^2);

h = @(x) (mean(x) - real_var);
m(:,v) = cellfun(h, statDist);

etta(1,v) = SStime/SStot;
etta(2,v) = SSreward/SStot;
etta(3,v) = SSerror/SStot;


% m(2,:)= cellfun(@median, var_est); 
% subplot(2,4,5); hold on;
% plot(m);
% legend(names);
% d_prime(1,v) = (mean(statDist{1}) - mean(statDist{2}))/...
%     sqrt(0.5*(var(statDist{1})+var(statDist{2})));
% d_prime(2,v) = (mean(statDist{1}) - mean(statDist{3}))/...
%     sqrt(0.5*(var(statDist{1})+var(statDist{3})));

end

figure;
subplot(1,2,1)
names = {'independent', 'total', 'time only', 'reward only'};
plot(var_vals,m);
legend(names);
xlabel('noise')
ylabel('dist mean')

subplot(1,2,2)
plot(var_vals,etta);
legend('time only', 'reward only');
xlabel('noise')
ylabel('eta')


%%
clear

statistic_func = @intergroupVar;

%statistic_func = @(smpl)  var(reshape(squeeze(mean(smpl)),1,[]));

T = 10;
N_TRIAL = 800; %average per condition
var_vals = 40;
numCells = 80;

match_d = [];
for d=1:8
match_d = [match_d; d*ones(N_TRIAL/8,1)];
end

for ii = 1:numCells

match = [ones(N_TRIAL/2,1);2*ones(N_TRIAL/2,1)];

match = [match, match_d(randperm(length(match_d)))];

response = [rand([ T, N_TRIAL])] *var_vals;

statDist{ii} = permVarFrac(response',match,statistic_func);

    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match(:,1)',size(response,1),1);
    groupD = repmat(match(:,2)',size(response,1),1);

[p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
totVar = tbl{9,2};
msw = tbl{8,5};
ettaT(ii) = tbl{2,2}/totVar;
ettaR(ii) = tbl{5,2}/totVar;
ettaD(ii) = tbl{6,2}/totVar;

omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
omegaT(ii) = omega(tbl,2);
omegaR(ii) = omega(tbl,5);
omegaD(ii) = omega(tbl,6);

epsilon = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(totVar)
epsilonT(ii) = epsilon(tbl,2);
epsilonR(ii) = epsilon(tbl,5);
epsilonD(ii) = epsilon(tbl,6);

end

%%
h = @(x,dim) (mean(x{2})-mean(x{dim}));%*(mean(x{1})-x{end}...
      %  /mean(x{1})^2);
f = @(x) (mean(x{1} > x{4}))>(1-0.05);
hReward = @(x) h(x,3);
hDirection = @(x) h(x,4);
hTime = @(x,dim) (mean(x{1})-mean(x{2}));
rewardCost = cellfun(hReward,statDist);
dirCost = cellfun(hDirection,statDist);
timeCost = cellfun(hTime,statDist);
inx = find(cellfun(f,statDist));
figure;
scatter(rewardCost,dirCost); hold on
scatter(rewardCost(inx),dirCost(inx)); hold on
xlabel('Total-reward')
ylabel('Total-direction')
p = signrank(rewardCost,dirCost);
title(['p = ' num2str(p)])
axis equal
refline(1,0)

figure;
m = [timeCost;rewardCost;dirCost];
plot([1,2,3],m,'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'total-time', 'time-reward' ,'time-direction'})
title('bootstrap')


figure;
plot([1,2,3],[omegaT;omegaR;omegaD],'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'time', 'time*reward' ,'time*direction'})
title('omega')
 

figure;
plot([1,2,3],[ettaT;ettaR;ettaD],'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'time', 'time*reward' ,'time*direction'})
title('etta')


figure;
plot([1,2,3],[epsilonT;epsilonR;epsilonD],'ob'); hold on
xticks([1:3])
xlim([0 4])
xticklabels({'time', 'time*reward' ,'time*direction'})
title('epsilon')

 