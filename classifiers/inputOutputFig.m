function inputOutputfig(effect, cellType)

figure; 
REPEATS = 10000;

pops = {'SNR','BG msn','PC ss','CRB'};
cols = {'r','y','b','g'};

x1 = subplot(2,1,1); hold on
x2 = subplot(2,1,2); hold on


for i = 1:length(pops)
    indType = find(strcmp(pops{i}, cellType));
    plot(x1,i,effect(indType),['o' cols{i}])
    errorbar(x2,i,nanmean(effect(indType)),nanSEM(effect(indType)),cols{i},'LineWidth',4)
end


p_val = bootstraspWelchANOVA(effect',cellType');
title(['p = ' num2str(p_val)])

end

