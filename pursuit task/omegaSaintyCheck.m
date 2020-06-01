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
        omegaEffecctSize(ii,j) = omega(tbl,2);
        
    end
    
end

plot(L,omegaEffecctSize,'o'); hold on
plot(L,mean(omegaEffecctSize),'ok','MarkerSize',16); 
figure;
hist(omegaEffecctSize(:,1),15)
