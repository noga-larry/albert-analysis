function statDist = permVarFrac(response,match,statistic_func, varargin)

permDims = size(match,2);

p = inputParser;
defaultPlot = false;
defaultBootNum = 1000;
defaultVarNames =  string(1:permDims);
defaultVarNames =  {'total',defaultVarNames{:}};
defaultTimes =  1:size(response,2);
addOptional(p,'plotCell',defaultPlot,@islogical);
addOptional(p,'Times',defaultTimes,@isnumeric);
addOptional(p,'bootNum',defaultBootNum,@isnumeric);
addOptional(p,'varNames',defaultVarNames);

parse(p,varargin{:})
bootNum = p.Results.bootNum;
plotFlag = p.Results.plotCell;
varNames =  p.Results.varNames;
ts = p.Results.Times;

real_stat = statistic_func(response,match);

tot_boot_var = nan(1,bootNum);

% shuufle all
for i=1:bootNum
    
    r_perm = randperm(numel(response));
    boot_vals = response(r_perm);
    boot_vals = reshape(boot_vals, size(response));
    tot_boot_var(i) = statistic_func(boot_vals,match);
    
end

if plotFlag
    
    subplot(2,permDims+2,permDims+3);
    hist(tot_boot_var,bootNum/20); hold on;
    plot([real_stat, real_stat], ylim, 'r'); hold off
    title('uncostraint shuffel')
end

statDist{1} = tot_boot_var;


% keep time constraint
constraint_stat = nan(1,bootNum);
boot_vals = response;

for i=1:bootNum
    for j=1:size(boot_vals,2)
        boot_vec = squeeze(boot_vals(:,j,:));
        r_perm = randperm(numel(boot_vec));
        boot_vec = reshape(boot_vec(r_perm),size(boot_vec));
        boot_vals(:,j,:) = boot_vec;
    end
    
    constraint_stat(i) = statistic_func(boot_vals,match);
end

statDist{2} = constraint_stat;

if plotFlag
    
    subplot(2,permDims+2,2);
    plot(ts,squeeze(nanmean(response))); hold off
    title(['time constraint'])
    
    subplot(2,permDims+2,permDims+4);
    hist(constraint_stat,bootNum/20); hold on
    plot([real_stat, real_stat], ylim, 'r'); hold off
    title(['time constraint'])
    
end


for s = 1:permDims
    if permDims>1
        match_dim = match(:,s);
    else
       match_dim = match; 
    end
    constraint_stat = nan(1,bootNum);
    boot_vals = nan(size(response));
    groups = unique(match_dim,'rows');
    
    for i=1:bootNum
        for j=1:length(groups)
            indRows = find(match_dim==groups(j));
            for k=1:size(boot_vals,2)
                boot_vec = squeeze(response(indRows,k));
                r_perm = randperm(numel(boot_vec));
                boot_vec = reshape(boot_vec(r_perm),size(boot_vec));
                boot_vals(indRows,k,:) = boot_vec;
            end
        end
        constraint_stat(i) = statistic_func(boot_vals,match);
        
    end
    if plotFlag
        
        subplot(2,permDims+2,2+s);
        
        for i=1:length(groups)
            plot(ts,squeeze(nanmean(response(match_dim==groups(i),:)))); hold on
        end
        hold off       
        title([varNames{s} ' constraint'])
        
        subplot(2,permDims+2,permDims+4+s);
        hist(constraint_stat,bootNum/20); hold on;
        plot([real_stat, real_stat], ylim, 'r'); hold off
        title([varNames{s} ' constraint'])
        
    end
    
    statDist{2+s} = constraint_stat;
    
    if plotFlag
    subplot(2,permDims+2,1);
    h = @(x) ((mean(statDist{2})-mean(x)))
    m = cellfun(h,statDist);
    n = cellfun(@mean,statDist);
    subplot(4,(permDims+2),1);
    plot([m h(real_stat)]); hold off
    subplot(4,(permDims+2),permDims+3);
    plot([n mean(real_stat)]); hold off
    xticklabels({'total','time',varNames{:},'ind'})
   
    end
    
    statDist{end+1} = real_stat;
    
end



