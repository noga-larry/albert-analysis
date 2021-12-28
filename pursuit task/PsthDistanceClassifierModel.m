classdef PsthDistanceClassifierModel < ClassifierModel
    
    properties
        psthMap
        SD = 30
        smoothingMargins = 300
    end
    
    methods
        
        function mdl = train(mdl,X,y)
            psthMap = containers.Map('KeyType','double','ValueType','any');
            classes = unique(y);
            for i = 1:length(classes)
                ind = find(y == classes(i));
                psth = mdl.psthCal(X(:,ind));
                psthMap(classes(i)) = psth;
            end
            mdl.psthMap = psthMap;            
        end
        
        function pred = predict(mdl,X)
            pred = nan(size(X,2),1);
            classes = mdl.psthMap.keys;
            for i = 1:size(X,2)
                trialPsth = mdl.psthCal(X(:,i));
                dists = nan(1,length(classes));
                for j = 1:length(classes)
                    dists(j) = sum(abs(trialPsth - mdl.psthMap(classes{j}))) ;
                end
                [~,ind] = min(dists);
                pred(i) =  classes{ind};
            end            
        end
        
        function psth = psthCal(mdl,X)
%             psth = nanmean(X,2);
%             psth = gaussSmooth(psth,mdl.SD);
%             psth = psth((mdl.smoothingMargins+1):(length(psth)-mdl.smoothingMargins));
            params.smoothing_margins = mdl.smoothingMargins;
            params.SD = mdl.SD;
            psth = raster2psth(X,params);
        end
        
    end
end