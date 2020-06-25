% Probability Cue Response
clear all;
supPath = 'C:\Users\Noga\Documents\Vermis Data';
load ('C:\Users\Noga\Documents\Vermis Data\task_info');

% Make list of significant cells

req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.remove_question_marks = 1;
req_params.grade = 10;
req_params.cell_type = 'CRB|PC ss';

raster_params.align_to = 'cue';
raster_params.time_before = 200;
raster_params.time_after = 600;
raster_params.smoothing_margins = 0;
req_params.num_trials = 50;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    raster = getRaster(data,find(~boolFail),raster_params);
    FR(ii) = mean(mean(raster)*1000);
    CV2(ii) = nanmean(getCV2(data,find(~boolFail),raster_params));
    CV(ii) = nanmean(getCV(data,find(~boolFail),raster_params));
end

figure
boolPC = strcmp('PC ss', cellType);
scatter(FR(boolPC),CV2(boolPC),'k'); hold on
scatter(FR(~boolPC),CV2(~boolPC),'m')
legend('PC ss','CRB')
xlabel('FR'); ylabel('CV2')

figure
boolPC = strcmp('PC ss', cellType);
scatter(FR(boolPC),CV(boolPC),'k'); hold on
scatter(FR(~boolPC),CV(~boolPC),'m')
legend('PC ss','CRB')
xlabel('FR'); ylabel('CV')

figure
plotHistForFC(CV(boolPC),20,'k'); hold on
plotHistForFC(CV(~boolPC),20,'m'); hold on
legend('PC ss','CRB')
xlabel('FR')