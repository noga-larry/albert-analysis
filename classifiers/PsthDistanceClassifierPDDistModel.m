classdef PsthDistanceClassifierPDDistModel < PsthDistanceClassifierModel

    properties
        PD
    end

    methods

    function mdl = PsthDistanceClassifierPDDistModel(PD)
            mdl.PD = PD;
    end

    function dist = evaluate(mdl,X,y)
        preds = mdl.predict(X);
        dist = mean(angleDistance(preds-mdl.PD,y'-mdl.PD));
    end
end



end