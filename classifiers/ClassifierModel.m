classdef ClassifierModel
    
    methods (Abstract)
        train(mdl,X,y)
        predict(mdl,X,y)
    end

    methods

        function accuracy = evaluate(mdl,X,y)
            preds = mdl.predict(X);
            accuracy = mean((preds==y'));
        end
    end
end