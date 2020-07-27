clear all
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

req_params.grade = 10;
req_params.cell_type = 'PC|CRB';
req_params.task = 'choice';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 0;
req_params.remove_repeats = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
probabilities  = [0:25:100];

fracChoice = nan(length(lines),length(probabilities),length(probabilities)); 

for ii = 33:length(cells)
    
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
  
imagesc(probabilities,probabilities,squeeze(nanmean(fracChoice)))