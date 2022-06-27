classdef KnnClassifierModel < ClassifierModel
    
    properties
        NumNeighbors
        knnObject
    end
    
    methods
        
        function mdl = KnnClassifierModel(k)
            if nargin > 0
                mdl.NumNeighbors = k;
            end
        end
        
        function mdl = train(mdl,X,y)
            
            mdl.knnObject = fitcknn(sum(X)',y,'NumNeighbors',mdl.NumNeighbors);
        end
        
        function preds = predict(mdl,X,y)
            preds = mdl.knnObject.predict(sum(X)');
        end
        
    end
end