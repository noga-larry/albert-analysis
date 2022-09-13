clear; clc
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

POPULATIONS = {'BG|SNR','BG|SNR';...
    'BG|SNR','PC ss|CRB';...
    'PC ss|CRB','PC ss|CRB'};
BIN_SIZE = 10;
DIRECTIONS = 0:45:315;
PROBABILIES = [25,75];
PLOT_PAIR = false;

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
req_params.task = 'saccade_8_dir_75and25|pursuit_8_dir_75and25';

for ii=1:size(POPULATIONS,1)
    req_params.cell_type = POPULATIONS{ii,1};
    lines1 = findLinesInDB (task_info, req_params);
    req_params.cell_type = POPULATIONS{ii,2};
    lines2 = findLinesInDB (task_info, req_params);
    pairs{ii} = findPairs(task_info,lines1,lines2,...
        req_params.num_trials);
end

ts = (-raster_params.time_before):BIN_SIZE:(raster_params.time_after-1);

c=0;
for ii=1:length(pairs)

    cur_pairs = pairs{ii};

    for j=1:length(cur_pairs)

        c=c+1;
        cells = findPathsToCells (supPath,task_info,[cur_pairs(j).cell1,cur_pairs(j).cell2]);
        data1 = importdata(cells{1});
        data2 = importdata(cells{2});

        [data1,data2] = reduceToSharedTrials(data1,data2);

        boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];

        [~,match_p] = getProbabilities(data1);
        for p = 1:length(PROBABILIES)
            inx = find(match_p==PROBABILIES(p) & ~ boolFail);
            psth1 = getSTpsth(data1,inx,raster_params);
            psth2 = getSTpsth(data2,inx,raster_params);

            % shift control
            %psth1 = psth1(1:end-1,:); psth2 = psth2(2:end,:);

            psth1 = downSampleToBins(psth1, BIN_SIZE);
            psth2 = downSampleToBins(psth2, BIN_SIZE);

            corr_mat(c,p,:,:) = corr(psth1,psth2);

        end

        if PLOT_PAIR
            for p = 1:length(PROBABILIES)
                subplot(2,1,p)
                imagesc(squeeze(corr_mat(c,p,:,:))); colorbar
                xlabel(['time from ' raster_params.align_to])
                ylabel(['time from ' raster_params.align_to])
                title(['P = ' num2str(PROBABILIES(p))])
            end
            sgtitle([POPULATIONS(ii,1) ' and ' POPULATIONS(ii,2)])
            pause
        end
        pop_inx(c)=ii;

    end
end


%%
figure
c=0;

for ii=1:size(POPULATIONS,1)
    
    inx = find(pop_inx==ii);

    for p = 1:length(PROBABILIES)
        c = c+1;

        subplot(size(POPULATIONS,1),length(PROBABILIES),c); hold on

        ave = squeeze(mean(corr_mat(inx,p,:,:),"omitnan"));
        imagesc(ts,ts,ave);colorbar

        xlabel('Time from cue'); ylabel('Time from cue')
        title([POPULATIONS{ii,1} ' and ' POPULATIONS{ii,2}], FontSize=8)
        subtitle(['P = ' num2str(PROBABILIES(p))])
        xlim([min(ts) max(ts)]);ylim([min(ts) max(ts)])
        caxis([-0.05 0.1]);
    end
  
end

