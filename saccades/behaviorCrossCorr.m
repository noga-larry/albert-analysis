%% Behavior figure

clear

MAX_DELTA = 20;

[task_info,supPath] = ...
    loadDBAndSpecifyDataPaths('Vermis');

behavior_params.time_after = 250;
behavior_params.time_before = -100;
behavior_params.smoothing_margins = 100; % ms
behavior_params.SD = 15; % ms

req_params.grade = 7;
req_params.cell_type = {'PC ss', 'CRB','SNR','BG msn'};
req_params.task = "pursuit_8_dir_75and25";
req_params.ID = 4000:6000;
req_params.num_trials = 100;
req_params.remove_question_marks =1;

lines = findLinesInDB(task_info,req_params);
cells = findPathsToCells (supPath,task_info,lines);


behabiorAutocorr = nan(length(cells),MAX_DELTA+1);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    data = getBehavior(data,supPath);
    boolFail = [data.trials.fail];
    inx = find(~boolFail);

    if req_params.task  == "pursuit_8_dir_75and25"
        [~,~,H,~] = meanVelocitiesRotated(data,behavior_params,inx);
        behavior = mean(H,2,"omitnan");
    elseif req_params.task  == "saccade_8_dir_75and25"
        behavior = saccadeRTs(data,inx)';
    end

   [behabiorAutocorr(ii,:)] = autocorr(behavior,MAX_DELTA);



end

%%

figure
errorbar(1:MAX_DELTA, mean(behabiorAutocorr(:,2:end)),nanSEM(behabiorAutocorr(:,2:end)),'*')
ylabel('corr');xlabel('lag');
title(req_params.task,'Interpreter','none')
%%

function [r] = autocorr(behavior, maxDelta)

r = nan(1,maxDelta+1);
for ii=0:maxDelta
    r(ii+1) = corr(behavior(1:end-ii),behavior(1+ii:end),"rows","pairwise");
end

end
