
function mdl = classifierFactory(classifierType,PD)

switch classifierType
    case 'PsthDistance'
        mdl = PsthDistanceClassifierModel;
    case 'PopulationPsthDistance'
        mdl = PopulationPsthDistanceClassifierModel;
    case 'Knn'
        mdl = KnnClassifierModel;
    case 'PsthDistanceFromPD'
        mdl =PsthDistanceClassifierPDDistModel(PD);


end

end