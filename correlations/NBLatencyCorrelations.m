clear; clc
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

DIRECTIONS = 0:45:315;
PROBABILIES = [25,75];
BIN_SIZE = 100;

raster_params.time_before = 199;
raster_params.time_after = 800;
raster_params.smoothing_margins = 200;
raster_params.SD=15;
raster_params.align_to = 'cue';

req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = false;
req_params.num_trials = 120;
req_params.remove_repeats = false;
req_params.task = 'saccade_8_dir_75and25';
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};

ts = (-raster_params.time_before):BIN_SIZE:(raster_params.time_after-1);

lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);
nb_corr = nan(length(cells),length(PROBABILIES),length(ts));
nb_significance = nan(length(cells),length(PROBABILIES),length(ts));

for ii=1:length(cells)

    data = importdata(cells{ii});
    data = getBehavior(data,supPath);

    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;

    [r,p_val] =  LatencyNBCorr(data, PROBABILIES, DIRECTIONS, raster_params,...
        BIN_SIZE);

    nb_corr(ii,:,:) = r;
    nb_significance(ii,:,:) = p_val;

end



%%

figure

for p=1:length(PROBABILIES)
    subplot(2,2,p); hold on
    ylim([-0.1 0.1])
    for ii=1:length(req_params.cell_type)
        inx = find(strcmp(req_params.cell_type{ii},cellType));
        ave = squeeze(mean(nb_corr(inx,p,:),"omitnan"));
        sem = squeeze(nanSEM(nb_corr(inx,p,:)));
        errorbar(ts,ave,sem)
    end
    xlabel('Time from cue'); ylabel('ave corr')
    title(['P = ' num2str(PROBABILIES(p))])
    legend(req_params.cell_type)
    yline(0)

end

for p=1:length(PROBABILIES)
    subplot(2,2,2+p); hold on
    for ii=1:length(req_params.cell_type)
        inx = find(strcmp(req_params.cell_type{ii},cellType));
        ave = squeeze(mean(nb_significance(inx,p,:)<0.05,"omitnan"));
        sem = squeeze(nanSEM(nb_significance(inx,p,:)<0.05));
        errorbar(ts,ave,sem)
    end
    xlabel('Time from cue'); ylabel('Frac sig')
    title(['P = ' num2str(PROBABILIES(p))])
    yline(0.05)
    ylim([-0.05 0.25])
    legend(req_params.cell_type)
end
