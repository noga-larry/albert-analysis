clear all

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Golda');

NUM_COND = 20;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC|BG|SNR';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 180;
req_params.remove_question_marks =0;
req_params.remove_repeats = 0;

behavior_params.time_after = 300;
behavior_params.time_before = 0;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 10; % ms

displayTime = behavior_params.time_after+behavior_params.time_before+1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

probabilities  = [0:25:100];
velH = nan(NUM_COND,length(cells),displayTime);
velV = nan(NUM_COND,length(cells),displayTime);


for ii = 1:length(cells)
    
    condCounter = 0;
    data = importdata(cells{ii});
    data = getBehavior(data,MaestroPath);
    
    [probabilities,match_p] = getProbabilities (data);
    [~,match_d] = getDirections(data);
    boolFail = [data.trials.fail] & ~[data.trials.choice];
    
    for j = 1:length(probabilities)
        for  k = j+1:length(probabilities)
            boolProb = (match_p(1,:) == probabilities(k) & ...
                match_p(2,:) == probabilities(j));
            condCounter = condCounter+1;
            boolDir = match_d(1,:)==90;
            
            
            ind = find(boolProb & ~boolFail & boolDir);
            [velH(condCounter,ii,:),velV(condCounter,ii,:)] =...
                meanVelocitiesRotated(data,behavior_params,ind);
            
            condCounter = condCounter+1;
            boolDir = match_d(1,:)==0;
            ind = find(boolProb & ~boolFail & boolDir);
            [velH(condCounter,ii,:),velV(condCounter,ii,:)] =...
                meanVelocitiesRotated(data,behavior_params,ind);
        end
    end
    
end

aveVelH = squeeze(mean(velH,2));aveVelV = squeeze(mean(velV,2));

%%
condCounter = 0;

for j = 1:length(probabilities)
    for  k = j+1:length(probabilities)
        condCounter = condCounter+1;
        
        probCondition(1,condCounter) = probabilities(j);
        probCondition(2,condCounter) = probabilities(k);
        
        leg{condCounter} = [num2str(probabilities(j)) ' vs ' num2str(probabilities(k))];
        
        
        condCounter = condCounter+1;
        
        probCondition(1,condCounter) = probabilities(j);
        probCondition(2,condCounter) = probabilities(k);
        
        leg{condCounter} = '';
        
    end
end

%%
figure; hold on
c = varycolor(length(leg)/2);
col = nan(length(leg),3);
col(1:2:end,:) = c; col(2:2:end,:) = c; 
for j=1:length(leg)
    plot(aveVelH(j,:)',aveVelV(j,:)','Color',col(j,:))
end


legend(leg,'Location','northwest')
equalAxis
xlabel('Horizontal Vel')
ylabel('Vertical Vel')


%% Quantify Bias

angles = abs(atand(nanmean(velV(:,:,end-50:end),3) ./...
    nanmean(velH(:,:,end-50:end),3)));

figure; hold on
X = []; y =[];
for j=1:length(leg)
    x_axis = min([probCondition(2,j),probCondition(1,j)]);
    errorbar(x_axis,...
        mean(angles(j,:)),...
        std(angles(j,:)),...
        'Color',col(j,:),'Marker','*')
    X = [X,x_axis];
    y = [y,mean(angles(j,:))];
end
legend(leg)

mdl = fitlm(X,y);

title(['R^2_{adjusted} = ' num2str(mdl.Rsquared.Adjusted)])