
function mdl = classifierFactory(classifierType)
switch classifierType
    case 'PsthDistance'
        mdl = PsthDistanceClassifierModel;
    case 'PopulationPsthDistance'
        mdl = PopulationPsthDistanceClassifierModel;
        
    case 'Knn'
        mdl = KnnClassifierModel;
        
end

end