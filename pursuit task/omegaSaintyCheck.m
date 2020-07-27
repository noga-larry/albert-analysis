N = 1000;
T =20; 
L = 2:10;
for j=1:length(L)
    for ii = 1:N
        
        response = randn(1,T);     
        group = mod(1:T,L(j));
        
        [p,tbl,stats,terms] = anovan(response(:),{group(:)},...
            'model','interaction','display','off');
        
        SST = tbl{4,2};
        msw = tbl{3,5};
        
        omega = @(tbl,dim) (tbl{dim,2}-tbl{dim,3}*msw)/(msw+SST);
        etta = @(tbl,dim) tbl{dim,2}/SST;
        omegaEffectSize(ii,j) = omega(tbl,2);
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
