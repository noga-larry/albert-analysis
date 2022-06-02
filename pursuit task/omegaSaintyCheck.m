REPEATS = 1000;
T = 100; 
L = 2:10;

ettaEffectSize = nan(REPEATS,length(L));
omegaEffectSize = nan(REPEATS,length(L));

for j=1:length(L)
    for ii = 1:REPEATS
        
        response = randn(1,T);     
        group = mod(1:T,L(j));
        
        [~,tbl,~,~] = anovan(response(:),{group},'model','full','display','off','sstype',2);
        
        totVar = tbl{end,2};
        msw = tbl{end-1,5};
        SSe = tbl{end-1,2};
        N = length(response(:));
        
        omegafun = @(tbl,dim) (sum([tbl{dim,2}])-(sum([tbl{dim,3}])*msw))/...
            (sum([tbl{dim,2}])+(N-sum([tbl{dim,3}]))*msw);
        
        etta = @(tbl,dim) tbl{dim,2}/(tbl{dim,2}+tbl{end-1,2});
        
        omegaEffectSize(ii,j) = omegafun(tbl,2);
        ettaEffectSize(ii,j) = etta(tbl,2);
    end
    
end
%%
figure;
subplot(2,2,1)
col = varycolor(length(L));
for i = 1:length(L)
    plotHistForFC(omegaEffectSize(:,i),-1:0.1:1,'Color',col(i,:)); hold on
    leg{i} = num2str(L(i));
end
legend(leg)
title('Omega')
subplot(2,2,2)
for i = 1:length(L)
    plotHistForFC(ettaEffectSize(:,i),-1:0.1:1,'Color',col(i,:)); hold on
    leg{i} = num2str(L(i));
end
legend(leg)
title('Etta')
subplot(2,1,2)
plot(L,mean(omegaEffectSize),'k'); hold on
plot(L,mean(ettaEffectSize),'m'); hold on
legend('Omega','Etta')
ylabel('Mean Effect Size')
xlabel('# of levels')
