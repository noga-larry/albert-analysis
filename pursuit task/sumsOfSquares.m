function ss = sumsOfSquares(y,groups)

ss.total = var(y)*(length(y)-1);
tot_mean = mean(y);


% Design Mat
levels_a  = unique(groups{1});
levels_b  = unique(groups{2});

DFa = length(unique(levels_a))-1;
DFb = length(unique(levels_b))-1;
N = length(groups{1});
X = nan(N,DFa+DFb+DFa*DFb);
first_ind_a = 1;
first_ind_b = 1+DFa;
first_ind_ab = first_ind_b+DFb;

dummys_a = cell(1,DFa); dummys_b = cell(1,DFb); 
for i=1:DFa; h = @(x) x==levels_a(i); dummys_a{i} = h; end
for i=1:DFb; h = @(x) x==levels_b(i); dummys_b{i} = h; end

% main effects
for i=1:DFa
    ha = dummys_a{i};
    X(:,first_ind_a+i-1) = ha(groups{1});   
    for j = 1:DFb
        hb = dummys_b{j};
        X(:,first_ind_b+j-1) = hb(groups{2});
        intr_ind = first_ind_ab +(i-1)*DFb+j-1;
        X(:,intr_ind)  =  hb(groups{2}) & ha(groups{1});         
    end
end


% error and complete model
mdl = fitlm(X,y);
ss.error = mdl.SSE;

total_model_ssreg = mdl.SSR;

% effect a
patrial_X = X;
%patrial_X(:,first_ind_ab:end) = [];
patrial_X(:,first_ind_a:(first_ind_b-1)) = [];
mdl = fitlm(patrial_X,y);
ss.X1 = total_model_ssreg - mdl.SSR;

% effect b
patrial_X = X;
%patrial_X(:,first_ind_ab:end) = [];
patrial_X(:,first_ind_b:(first_ind_ab-1)) = [];
mdl = fitlm(patrial_X,y);
ss.X2 = total_model_ssreg - mdl.SSR;

% effect ab
patrial_X = X;
patrial_X(:,first_ind_ab:end) = [];
mdl = fitlm(patrial_X,y);
ss.interaction = total_model_ssreg - mdl.SSR;

% 
% % main effects
% for i=1:length(groups)
%     levels = groups{i};
%     unique_levels=unique(levels);
%     level_means = nan(1,length(unique_levels));
%     ns = nan(1,length(unique_levels)); 
%     for j = 1: length(unique_levels)
%         inx = find(levels == unique_levels(j));
%         level_means(j) = mean(y(inx)); 
%         ns(j) = length(inx);
%     end    
%     ss.(['X' num2str(i)]) = sum(ns.*((level_means - tot_mean).^2));
% end
% 
% % error
% sse = 0;
% 
% levels = [groups{:}];
% unique_levels=unique(levels,'rows');
% for j = 1: length(unique_levels)
%     inx = find(levels(:,1)==unique_levels(j,1) & levels(:,2)==unique_levels(j,2));
%     level_mean= mean(y(inx));
%     sse = sse + sum((y(inx) - level_mean).^2);
% end
% 
% 
% ss.error = sse;
% ss.interaction = ss.total - ss.X1- ss.X2 - ss.error;
