clear all
[task_info,supPath,MaestroPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC ss|CRB|SNR|BG';
req_params.task = 'choice';
req_params.num_trials = 120;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 0;
req_params.ID = 5000:6000;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
PROBABILITIES  = [0:25:100];

fracChoice = nan(length(lines),length(PROBABILITIES),length(PROBABILITIES));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p_tmp] = getProbabilities (data);
    [~,match_d] = getDirections (data);
    boolFail = [data.trials.fail];
    
    match_p = match_p_tmp;
    
%     match_p(1,match_d(1,:)==90) = match_p_tmp(2,match_d(1,:)==90);
%     match_p(2,match_d(1,:)==90) = match_p_tmp(1,match_d(1,:)==90);
    
    for j = 1:length(PROBABILITIES)
        for  k = 1:length(PROBABILITIES)
            
            boolProb = (match_p(1,:) == PROBABILITIES(k) & ...
                match_p(2,:) == PROBABILITIES(j));
            ind = find(boolProb & ~boolFail);
            fracChoice(ii,j,k) = ...
                mean([data.trials(ind).choice]);
        end
    end
end

%%
figure
imagesc(PROBABILITIES,PROBABILITIES,squeeze(nanmean(fracChoice)))
colorbar


% subplot(2,1,2)
% imagesc(PROBABILITIES,PROBABILITIES,squeeze(nanSEM(fracChoice)))
% colorbar
%%
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
PROBABILITIES  = [0:25:100];

fracChoice = nan(length(lines),length(PROBABILITIES),length(PROBABILITIES));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    condCounter = 1;
    
    for j = 1:length(PROBABILITIES)
        for  k = j+1:length(PROBABILITIES)
            boolProb = (match_p(1,:) == PROBABILITIES(k) & ...
                match_p(2,:) == PROBABILITIES(j));
            ind = find(boolProb & ~boolFail);
            fracChoice(ii,condCounter) = ...
                mean([data.trials(ind).choice]);
            probCondition(1,condCounter) = PROBABILITIES(j);
            probCondition(2,condCounter) = PROBABILITIES(k);
            leg{condCounter} = [num2str(PROBABILITIES(j)) ' vs ' num2str(PROBABILITIES(k))];
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
        mean(fracChoice(:,j)),...
        std(fracChoice(:,j)),...
        'Color',col(j,:),'Marker','*') 
end
legend(leg)
mdl = fitlm(x_axis,mean(fracChoice));

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
PROBABILITIES  = [0:25:100];

fracChoice = nan(length(lines),length(PROBABILITIES),length(PROBABILITIES));

for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    [~,match_p] = getProbabilities (data);
    boolFail = [data.trials.fail];
    
    for j = 1:length(PROBABILITIES)
        for  k = 1:length(PROBABILITIES)
            
            currentProbability = sort([PROBABILITIES(j),PROBABILITIES(k)],'descend');
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
h = imagesc(PROBABILITIES,PROBABILITIES,squeeze(nanmean(fracChoice)));
xticks(0:25:100);yticks(0:25:100); colorbar
