function ave_accuracy = trainAndTestClassifier...
    (classifierType,response,labels,crossValSets)

kFold = size(crossValSets,1);
accuracy = nan(kFold,1);
for k = 1:kFold
    training_set = response(:,crossValSets{k,2});
    training_labels = labels(crossValSets{k,2});
    test_set = response(:,crossValSets{k,1});
    test_labels = labels(crossValSets{k,1});
    
    mdl = classifierFactory(classifierType);
    mdl = mdl.train(training_set,training_labels);
    accuracy(k) = mdl.evaluate(test_set,test_labels);
end

ave_accuracy = mean(accuracy);
end
