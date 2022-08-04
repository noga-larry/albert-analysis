clear all

N = 10000; %total

N1 = 0:10:N;
N2 = N-N1;

K = 1:10:N;
ALPHA = 0.1;
snr = nan(length(N1),length(K));

for i = 1:length(N1)
    x = N1(i)/N;
    for j = 1:length(K)
        s = ALPHA*((N1(i)-N2(i))/(N1(i)+N2(i)))^2;
        n = (1-ALPHA)*(1/(sqrt(K(j))*(N1(i)+N2(i))))^2;
        snr(i,j) = s/n;
        
    end
end
   

%%
figure;
imagesc(x,K,snr); colorbar
ylabel('N1/N')
xlabel('K')