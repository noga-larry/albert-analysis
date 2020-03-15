%% does adding an effect for movement reduce the omega for other variables?

clear all


T = 10;
N_TRIAL = 80; %average per condition
effect_size = [0:20];
var_vals = 40;
N_CELL = 80;
t_response = [3:5];

match_d = [];
for d=1:8
    match_d = [match_d; d*ones(N_TRIAL/8,1)];
end
match_p = [ones(N_TRIAL/2,1);2*ones(N_TRIAL/2,1)];

for i = 1:length(effect_size)
    
    for j=1:N_CELL
    
    response = [rand([ T, N_TRIAL])] *var_vals;
    
    match_p = match_p(randperm(length(match_p)));
    match_d = match_d(randperm(length(match_d)));
    
    for d=1:8
        ind = find(match_d == d);
        response(t_response,ind) = ...
            response(t_response,ind) + ones(length(t_response),length(ind))*d*effect_size(i);
    end
    

    groupT = repmat((1:size(response,1))',1,size(response,2));
    groupR = repmat(match_p',size(response,1),1);
    groupD = repmat(match_d',size(response,1),1);
    
    [p,tbl,stats,terms] = anovan(response(:),{groupT(:),groupR(:),groupD(:)},...
        'model','interaction','display','off');
    
    totVar = tbl{9,2};
    msw = tbl{8,5};
    
    omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+totVar);
    omegaT(j,i) = omega(tbl,2);
    omegaR(j,i) = omega(tbl,3)+omega(tbl,5);
    omegaD(j,i) = omega(tbl,4)+omega(tbl,6);
    
    
    end
    
end

%%

plot(effect_size,omegaD,'o');
plot(effect_size,omegaR,'o');
plot(effect_size,omegaT,'o');
