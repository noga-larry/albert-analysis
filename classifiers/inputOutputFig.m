function inputOutputfig(effect, cellType)

figure; 
REPEATS = 10000;

pops = {'SNR','BG msn','PC ss','CRB'};
cols = {'r','y','b','g'};

x1 = subplot(3,1,1); hold on
x2 = subplot(3,1,2); hold on


for i = 1:length(pops)
    indType = find(strcmp(pops{i}, cellType));
    plot(x1,i,effect(indType),['o' cols{i}])
    errorbar(x2,i,nanmean(effect(indType)),nanSEM(effect(indType)),cols{i},'LineWidth',4)
end

% bootstrap interaction test
effectForTest = effect;

% remove area mean


inx = find(strcmp('CRB', cellType)|strcmp('PC ss', cellType));
effectForTest(inx) = effectForTest(inx) - nanmean(effect(inx));
inx = find(strcmp('BG msn', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effectForTest(inx) - nanmean(effect(inx));

% remove in\out mean
inx = find(strcmp('CRB', cellType)|strcmp('BG msn', cellType));
effectForTest(inx) = effectForTest(inx) - nanmean(effect(inx));
inx = find(strcmp('PC ss', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effectForTest(inx) - nanmean(effect(inx));


ssb_true = ssb_stat(effectForTest, cellType);
for i = 1:REPEATS
    p_vec = permVec(effectForTest);
    ssb(i) = ssb_stat(p_vec, cellType);
end

subplot(3,1,3); hold on

histogram(ssb,'Normalization','Probability')
xline(ssb_true,'r','LineWidth',2)
p_val = mean(ssb >= ssb_true); 
title(['p = ' num2str(p_val)])

end

function ssb = ssb_stat(vec, labels)

v = [nanmean(vec(strcmp('CRB', labels))),nanmean(vec(strcmp('PC ss', labels)))...
    ,nanmean(vec(strcmp('SNR', labels))),nanmean(vec(strcmp('BG msn', labels)))];
v = v - nanmean(vec);
ssb = sum(v.^2);
end

