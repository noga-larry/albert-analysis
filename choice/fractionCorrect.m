clear all
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB|SNR|BG';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 80;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
probabilities  = [0:25:100];

fracChoice = nan(length(lines),length(probabilities),length(probabilities));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    condCounter = 1;
    
    for j = 1:length(probabilities)
        for  k = j+1:length(probabilities)
            boolProb = (match_p(1,:) == probabilities(k) & ...
                match_p(2,:) == probabilities(j));
            ind = find(boolProb & ~boolFail);
            fracCorrect(ii,condCounter) = ...
                mean([data.trials(ind).choice]);
            probCondition(1,condCounter) = probabilities(j);
            probCondition(2,condCounter) = probabilities(k);
            leg{condCounter} = [num2str(probabilities(j)) ' vs ' num2str(probabilities(k))];
            condCounter = condCounter+1;
        end
    end
end

%%

close all
regress_by = 'diff';

figure; hold on

switch regress_by
    case 'diff'
        x_axis = probCondition(2,:)-probCondition(1,:);
    case 'ratio'
        x_axis = probCondition(2,:).\probCondition(1,:);
    case 'min'
        x_axis = min([probCondition(2,:);probCondition(1,:)]);
    case 'max'
        x_axis = max([probCondition(2,:);probCondition(1,:)]);
end
col = varycolor(length(leg));

for j=1:length(leg)
    errorbar(x_axis(j),...
        mean(fracCorrect(:,j)),...
        std(fracCorrect(:,j)),...
        'Color',col(j,:),'Marker','*') 
end
legend(leg)
mdl = fitlm(x_axis,mean(fracCorrect));

ylabel('fraction correct')
xlabel(regress_by)
title(['R^2_{adjusted} = ' num2str(mdl.Rsquared.Adjusted)])


%%

clear all
[task_info,supPath,MaestroPath] = loadDBAndSpecifyDataPaths('Golda');


req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB|SNR|BG';
req_params.task = 'choice';
req_params.ID = 4000:5845;
req_params.num_trials = 80;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
probabilities  = [0:25:100];

fracChoice = nan(length(lines),length(probabilities),length(probabilities));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    for j = 1:length(probabilities)
        for  k = 1:length(probabilities)
            
            currentProbability = sort([probabilities(j),probabilities(k)],'descend');
            probabilityBool = (match_p(1,:) == currentProbability(1) & ...
                match_p(2,:) == currentProbability(2));
            ind = find(probabilityBool & ~boolFail);
            if j>k
                fracChoice (ii,j,k) = mean([data.trials(ind).choice]);
            else
                fracChoice (ii,j,k) =1- mean([data.trials(ind).choice]);
            end
        end
    end
end

figure;
h = imagesc(probabilities,probabilities,squeeze(nanmean(fracChoice)));
xticks(0:25:100);yticks(0:25:100); colorbar
