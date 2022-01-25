function accuracy = trainAndTestClassifier...
    (classifierType,response,labels,crossValSets)

kFold = size(crossValSets,1);
accuracy = nan(kFold,1);
for k = 1:kFold
    training_set = response(:,crossValSets{k,2});
    training_labels = labels(crossValSets{k,2});
    test_set = response(:,crossValSets{k,1});
    test_labels = labels(crossValSets{k,1});
    
    mdl = clasifierFactory(classifierType);
    mdl = mdl.train(training_set,training_labels);
    accuracy(k) = mdl.evaluate(test_set,test_labels);
end

accuracy = mean(accuracy);
end

function mdl = clasifierFactory(classifierType)
    switch classifierType
        case 'PsthDistance'
            mdl = PsthDistanceClassifierModel;
    end
            
end