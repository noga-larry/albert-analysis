function inputOutputfig(effect, cellType)

figure; 
NUM_BINS = 50;
REPEATS = 10000;


indPositive = find(effect>0);
indNegative= find(effect<=0);

effecsForDisplay(indPositive) = log(effect(indPositive));
effecsForDisplay(indNegative) = -log(-effect(indNegative));

posBins = linspace(min(effecsForDisplay(indPositive)), max(effecsForDisplay(indPositive)), 40);
negBins = linspace(min(effecsForDisplay(indNegative)), max(effecsForDisplay(indNegative)), 10);



uniqueCellTypes = uniqueRowsCA(cellType');
col = varycolor(length(uniqueCellTypes));

subplot(2,1,1); hold on
leg = {};
tit ='';
for i = 1:length(uniqueCellTypes)
    
    indType = find(strcmp(uniqueCellTypes{i}, cellType));
    
    [countsPositive, centersPositive] = hist(effecsForDisplay(intersect(indType,indPositive)), posBins);
    [countsNegative, centersNegative] = hist(effecsForDisplay(intersect(indType,indNegative)), negBins);
    
    normalization = sum(countsPositive)+sum(countsNegative);
    countsPositive = countsPositive/normalization;
    countsNegative = countsNegative/normalization;
    
    plot(centersPositive,countsPositive,'Color',col(i,:))
    plot(centersNegative,countsNegative,'Color',col(i,:))
    
    leg{end+1} = uniqueCellTypes{i};
    leg{end+1} = uniqueCellTypes{i};
    
    tit = [tit ' ' uniqueCellTypes{i} ' = ' num2str(length(indType)) ];
end

title(tit)
legend(leg)



% bootstrap interaction test
effectForTest = effect;

% remove area mean


inx = find(strcmp('CRB', cellType)|strcmp('PC ss', cellType));
effectForTest(inx) = effectForTest(inx) - mean(effect(inx));
inx = find(strcmp('BG msn', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effectForTest(inx) - mean(effect(inx));

% remove in\out mean
inx = find(strcmp('CRB', cellType)|strcmp('BG msn', cellType));
effectForTest(inx) = effectForTest(inx) - mean(effect(inx));
inx = find(strcmp('PC ss', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effectForTest(inx) - mean(effect(inx));


ssb_true = ssb_stat(effectForTest, cellType);
for i = 1:REPEATS
    p_vec = permVec(effectForTest);
    ssb(i) = ssb_stat(p_vec, cellType);
end

subplot(2,1,2); hold on

histogram(ssb,'Normalization','Probability')
xline(ssb_true,'r','LineWidth',2)
p_val = mean(ssb >= ssb_true); 
title(['p = ' num2str(p_val)])

end

function ssb = ssb_stat(vec, labels)

v = [mean(vec(strcmp('CRB', labels))),mean(vec(strcmp('PC ss', labels)))...
    ,mean(vec(strcmp('SNR', labels))),mean(vec(strcmp('BG msn', labels)))];
v = v - mean(vec);
ssb = sum(v.^2);
end

