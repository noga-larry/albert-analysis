clear

DEGREES = 0:45:315;
GAUS_WIDTH = 1:5:150;
PD = 180;
NOISE_STD = 0:0.1:3;
NUM_TRIALS_PER_COND = 100;
REPEATS = 10000;

figure;
ax1 = subplot(1,2,1); hold(ax1,"on") 

for i = 1:length(GAUS_WIDTH)

  %  DEGREES = DEGREES(randperm(length(DEGREES),2));

    tc = normpdf(DEGREES,PD,GAUS_WIDTH(i));

    % normaliztion
    tc = tc - min(tc);
    tc = tc/max(tc);

   % plot(ax1,tc)
    
    
    tc_per_trial = repmat(tc,NUM_TRIALS_PER_COND,1);
    
    for j=1:length(NOISE_STD)
      
        for r=1:REPEATS

            response = tc_per_trial+NOISE_STD(j)*randn(size(tc_per_trial));
            labels = repmat(DEGREES,NUM_TRIALS_PER_COND,1);

            tmp = calOmegaSquare(response(:)',{labels(:)'},...
                'direction','includeTime',false);

            omega(r,i,j) = tmp.value';
        end
    end
end

xlabel(ax1,'direction')
ylabel(ax1,'TC')
%%
aveOmega = squeeze(mean(omega,1));
semOmega = squeeze(nanSEM(omega,1));

ax2 = subplot(1,2,2)
ax2 = errorbar(repmat(GAUS_WIDTH,length(NOISE_STD),1)',aveOmega,semOmega)

xlabel('TC width')
ylabel('Omega')
title('Effect size dependence on width for different STDs')

%%
load('saccade ave pop.mat')

aveOmega = squeeze(mean(omega,1));
semOmega = squeeze(nanSEM(omega,1));


figure;hold on
imagesc(GAUS_WIDTH,NOISE_STD,aveOmega')
colormap gray
xlabel('TC width')
ylabel('Noise STD')
colorbar



TOL = [0.008, 0.002,0.002,0.007];
col = {'r','y','b','g'};
for i = 1:length(pop_mean_effect)
    [x,y] = find(abs(aveOmega-pop_mean_effect(i))<TOL(i));
    [~, inxSort] = unique(x); 
    x = x(inxSort); y = y(inxSort);
    [~,inxSort]= sort(x);
    plot(GAUS_WIDTH(x(inxSort)),NOISE_STD(y(inxSort)),[col{i} '.'])
end