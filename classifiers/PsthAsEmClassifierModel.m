classdef PsthAsEmClassifierModel < ClassifierModel
   
    properties
        EmPSTHs
    end
    
    methods
        
        function mdl = train(mdl,X,y)
            psthMap = containers.Map('KeyType','double','ValueType','any');
            classes = unique(y);
            for i = 1:length(classes)
                ind = find(y == classes(i));
                psth = gaussSmooth(mean(X(:,ind),2),10);
                %psth = psth/sum(psth);
                psthMap(classes(i)) = psth;
            end
            mdl.EmPSTHs = psthMap;
        end
        
        function preds = predict(mdl,X)
            classes = mdl.EmPSTHs.keys;
            LL = nan(size(X,2),length(classes));
            for i=1:length(classes)
                psth = mdl.EmPSTHs(classes{i});
                LL(:,i) = X'*log(psth); % log likelihood   
            end
            [~,inx] = max(LL,[],2);
            preds = [classes{inx}]';
            
        end
        
    end
end