clear all

[task_info,supPath,MaestroPath] =...
    loadDBAndSpecifyDataPaths('Vermis');

NUM_COND = 20;
req_params.remove_repeats = 0;
req_params.grade = 7;
req_params.cell_type = 'CRB|PC|BG|SNR';
req_params.task = 'choice';
req_params.ID = 5000:6000;
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
fracCorrect = nan(NUM_COND,length(cells));

for ii = 1:length(cells)
    
    condCounter = 0;
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    
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
            
            ind = find(boolProb & ~boolFail);
            fracCorrect(condCounter,ii) = ...
                mean([data.trials(ind).choice]);
            
        end
    end
    
end

aveVelH = squeeze(mean(velH,2));aveVelV = squeeze(mean(velV,2));
fracCorrect = fracCorrect(2:2:end,:);
%%
condCounter = 0;

for j = 1:length(probabilities)
    for  k = j+1:length(probabilities)
        condCounter = condCounter+1;
        
        probCondition(1,condCounter) = probabilities(j);
        probCondition(2,condCounter) = probabilities(k);
        
        leg{condCounter} = [num2str(probabilities(j)) ...
            ' vs ' num2str(probabilities(k))];
        
        
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

clear leg

regress_by = 'diff';

angles = atand(nanmean(velV(:,:,end-50:end),3) ./...
    nanmean(velH(:,:,end-50:end),3));

figure; hold on
X = []; y =[];
for j=1:length(probCondition)/2
    
    switch regress_by
        case 'diff'
            x_axis = probCondition(2,2*j)-probCondition(1,2*j);
        case 'ratio'
            x_axis = probCondition(2,2*j).\probCondition(1,2*j);
        case 'min'
            x_axis = min([probCondition(2,2*j),probCondition(1,2*j)]);
        case 'max'
            x_axis = max([probCondition(2,2*j),probCondition(1,2*j)]);
    end
    
    
    angle_difference(j,:) = angles(2*j-1,:)-angles(2*j,:);
    errorbar(x_axis,...
        mean(angle_difference(j,:)),...
        std(angle_difference(j,:)),...
        'Color',col(2*j,:),'Marker','*')
    X = [X,x_axis];
    y = [y,mean(angle_difference(j,:))];
    leg{j} = [num2str(probCondition(2,2*j)) ' vs ' ...
        num2str(probCondition(1,2*j))];
end
legend(leg)

mdl = fitlm(X,y);

ylabel('angle difference (deg)')
xlabel(regress_by)
title(['R^2_{adjusted} = ' num2str(mdl.Rsquared.Adjusted)])

%%
figure; hold on
for j=1:length(leg)
    errorbar(X(j),...
        mean(fracCorrect(j,:)),...
        std(fracCorrect(j,:)),...
        'Color',c(j,:),'Marker','*') 
end
legend(leg)
mdl = fitlm(X,mean(fracCorrect,2));

%%
figure;
errorbar(mean(fracCorrect,2),mean(angle_difference,2),...
    std(angle_difference,1,2),std(angle_difference,1,2),...
    std(fracCorrect,1,2),std(fracCorrect,1,2),'.');

xlabel('fraction correct')
ylabel('pursuit bias')


%%

figure; hold on
for j=1:length(leg)
    plot(fracCorrect(j,:),...
        angle_difference(j,:),...
        '.','Color',c(j,:),'MarkerSize',12) 
end
legend(leg)


xlabel('fraction correct')
ylabel('pursuit bias')
xlim([0.5 1])
ylim([-90 90])