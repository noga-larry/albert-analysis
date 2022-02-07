classdef PopulationPsthDistanceClassifierModel < ClassifierModel
    
    properties
        psthMap
        SD = 30
        smoothingMargins = 300
    end
    
    methods
        
        function mdl = train(mdl,X,y)
            psthMap = containers.Map('KeyType','double','ValueType','any');
            classes = unique(y{1});
            for i = 1:length(classes)
                psth = [];
                for j=1:length(y)
                    ind = find(y{j} == classes(i));
                    raster = X{j};
                    psth = [psth; mdl.psthCal(raster(:,ind))];
                end
                psthMap(classes(i)) = psth;
            end
            mdl.psthMap = psthMap;
        end
        
        function pred = predict(mdl,X)
            
            pred = nan(size(X{1},2),1);
            classes = mdl.psthMap.keys;
            for i = 1:size(X{1},2)
                trialPsth =[];
                for j=1:length(X)
                    cell_X = X{j};
                    trialPsth = [trialPsth; mdl.psthCal(cell_X(:,i))];
                end
                dists = nan(1,length(classes));
                for j = 1:length(classes)
                    vec = (trialPsth - mdl.psthMap(classes{j})).^2;
                    if all(isnan(vec))
                        dist(j) = nan;
                    else
                        dists(j) = nansum(vec);
                    end
                end
                [~,ind] = min(dists);
                if any(isnan(dists))
                    continue
                end
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
        
        function accuracy = evaluate(mdl,X,y) 
            preds = mdl.predict(X);
            bool_correct = double(preds == y');
            bool_correct(isnan(preds))= nan;
            accuracy = nanmean(bool_correct);
        end
        
    end
end