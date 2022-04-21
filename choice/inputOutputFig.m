function inputOutputfig(effect, cellType)

figure; hold on
NUM_BINS = 50;
REPEATS = 1000; 


indPositive = find(effect>0);
indNegative= find(effect<=0);

effecsForDisplay(indPositive) = log(effect(indPositive))
effecsForDisplay(indNegative) = -log(-effect(indNegative))

posBins = linspace(min(effecsForDisplay(indPositive)), max(effecsForDisplay(indPositive)), 40);
negBins = linspace(min(effecsForDisplay(indNegative)), max(effecsForDisplay(indNegative)), 10);



uniqueCellTypes = uniqueRowsCA(cellType');
col = varycolor(length(uniqueCellTypes));

leg = {};
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
end

legend(leg)



% bootstrap interaction test
effectForTest = effect;

% remove area mean
inx = find(strcmp('CRB', cellType)|strcmp('PC ss', cellType));
effectForTest(inx) = effect(inx) - mean(effect(inx));
inx = find(strcmp('BG msn', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effect(inx) - mean(effect(inx));

% remove in\out mean
inx = find(strcmp('CRB', cellType)|strcmp('BG msn', cellType));
effectForTest(inx) = effect(inx) - mean(effect(inx));
inx = find(strcmp('PC ss', cellType)|strcmp('SNR', cellType));
effectForTest(inx) = effect(inx) - mean(effect(inx));





end