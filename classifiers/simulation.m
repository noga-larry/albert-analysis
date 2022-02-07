N = 1000;
T = 100;
P = 0.001;
BIN_SIZE = 50+300*2;
K_FOLD = 10;

for ii = 1:N
    
    labels = binornd(1,0.25,1,T);
    
    raster = binornd(1,P,BIN_SIZE,T);
    % raster = binornd(1,0.0001,size(raster));
    N = size(raster,2);
    cross_val_sets = getNonOverlappingPartions(1:N,K_FOLD);
    
    accuracy(ii) = trainAndTestClassifier...
        ('Knn',raster,labels,cross_val_sets);
    
end

figure; plotHistForFC(accuracy,-1:0.1:1)