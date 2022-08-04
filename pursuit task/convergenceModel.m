clear all

N = 10000; %total

N1 = 4000:1:5000;
N2 = N-N1;

K = 1:1:1000;
ALPHA = 0.0001;
ALPHA = 0.00609322;%caudate
snr_ratio = nan(length(N1),length(K));

for i = 1:length(N1)
    x(i) = N1(i)/N;
    for j = 1:length(K)
%         s = ALPHA*((N1(i)-N2(i))/(N1(i)+N2(i)))^2;
%         n = (1-ALPHA)*(1/K(j));
        snr_ratio(i,j) = K(j)*((N1(i)-N2(i))/(N1(i)+N2(i)))^2; 
    end
end

y = K/N;

%%
figure; hold on
imagesc(x,y,snr_ratio'); colorbar; hold on
xlabel('N1/N')
ylabel('K/N')

ef2snr = @(x) x/(1-x); 

AVE_BG = ef2snr(0.0428017)/ef2snr(0.00609322);
TOLERENCE = 0.1;
[row,col] = find(snr_ratio<(AVE_BG+TOLERENCE) & snr_ratio>(AVE_BG-TOLERENCE));

plot(x(row),y(col),'k')

AVE_VER = ef2snr(0.00959431)/ef2snr(0.00848835);
TOLERENCE = 0.01;
[row,col] = find(snr_ratio<(AVE_VER+TOLERENCE) & snr_ratio>(AVE_VER-TOLERENCE));

plot(x(row),y(col),'r')


legend('BG','Vermis')

%% slices

k_val = 201:100:501;

figure; hold on
for i=1:length(k_val)
    inx = find(K==k_val(i));
    
    p = snr_ratio(:,inx);
    
    

    
    
    plot(x,p,'b')
    
    [~,inx] = min(abs(AVE_BG-p));
    plot(x(inx),p(inx),'ok');
    
    [~,inx] = min(abs(AVE_VER-p));
    plot(x(inx),p(inx),'or');
    
    
    
    
end

legend('line','BG','Vermis')

xlabel('N1/N')
    ylabel('snr ratio')