
function mdl = classifierFactory(classifierType)
switch classifierType
    case 'PsthDistance'
        mdl = PsthDistanceClassifierModel;
end

end