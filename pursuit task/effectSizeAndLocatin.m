clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = 'PC|CRB';
req_params.task = 'saccade_8_dir_75and25';
req_params.ID = 4000:5000;
req_params.num_trials = 50;
req_params.remove_question_marks = 1;

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = data.info.cell_type;
    
    coordinates(ii,1) = data.info.X;
    coordinates(ii,2) = data.info.Y;
    omegaD(ii) = data.effect_sizes.movement.direction;

end

unique_coordinates = unique(coordinates,'Rows');
x_range = sort(unique_coordinates(:,1));
y_range = sort(unique_coordinates(:,2));
average_omega_D_grid = nan(length(x_range),length(y_range));
for ii = 1:size(unique_coordinates,1)
      ind  = find (coordinates(:,1) == unique_coordinates(ii,1) & ...
      coordinates(:,2) == unique_coordinates(ii,2));
      x_i = find(x_range == unique_coordinates(ii,1));
      y_i = find(y_range == unique_coordinates(ii,2));
      average_omega_D_grid(x_i,y_i) = mean(omegaD(ind));    
end

imagesc(x_range,y_range,average_omega_D_grid); colorbar