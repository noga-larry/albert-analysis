
fitFunc = @(b,x)  b(1) * exp( b(2) * cosd( x - b(3) ) );
errorFunc = @(b,x,y) sum((fitFunc(b,x)-y).^2);


opts = optimset('Display','off');
DIRECTIONS = 0:45:315;

REPEATS  = 1;
BASELINES = 1:100;

for i = BASELINES

    for r=1:REPEATS
        cosFun = i*cosd(DIRECTIONS-180);
        currErrorFunc = @(b) errorFunc(b, DIRECTIONS, cosFun);
        b = fminsearch(currErrorFunc,randn(1,3),opts);


        %     pred = fitFunc(b,0:360);
        %     plot(DIRECTIONS,cosFun,'*'); hold on
        %     plot(0:360, pred); hold off

        width(r,i) = abs(b(2));
        multiplier(r,i) = b(1);
    end

end

subplot(2,1,1)
errorbar(BASELINES,mean(width,1),std(width,1,1)/sqrt(REPEATS))
subplot(2,1,2)
errorbar(BASELINES,multiplier,std(multiplier,1,1)/sqrt(REPEATS))