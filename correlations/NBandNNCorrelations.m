clear; clc
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

POPULATIONS = {'BG msn|SNR','BG msn|SNR';...
    'BG msn|SNR','PC ss|CRB';...
    'PC ss|CRB','PC ss|CRB'};
BIN_SIZE = 100;
SHIFT_CONTROL = 1;
INCLUDE_PREV_OUTCOME = true;

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
req_params.task = "saccade_8_dir_75and25";

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
        data1 = getBehavior(data1,supPath);
        data2 = getBehavior(data2,supPath);


        nb_corr1(c,:,:) = NBCorrFunction(data1, raster_params,...
            BIN_SIZE,req_params.task,'plotZScore',false,...
            'seperateByPrev', INCLUDE_PREV_OUTCOME);

        nb_corr2(c,:,:) = NBCorrFunction(data2, raster_params,...
            BIN_SIZE,req_params.task,'plotZScore',false, ...
            'seperateByPrev', INCLUDE_PREV_OUTCOME);

        if SHIFT_CONTROL
            nb_corr1_shift(c,:,:) = NBCorrFunction(data1, raster_params,...
                BIN_SIZE,req_params.task,'plotZScore',false,'shiftControl', true,...
                'seperateByPrev', INCLUDE_PREV_OUTCOME);


            nb_corr2_shift(c,:,:) = NBCorrFunction(data2, raster_params,...
                BIN_SIZE,req_params.task,'plotZScore',false,'shiftControl', true,...
                'seperateByPrev', INCLUDE_PREV_OUTCOME);
        end

        h(1,c) = task_info(cur_pairs(j).cell1).time_sig_motion;
        h(2,c) = task_info(cur_pairs(j).cell2).time_sig_motion;

        [nn_corr(c,:,:),nn_sig(c,:,:)] = NNCorrFunction(data1, data2,...
            raster_params, BIN_SIZE, 'seperateByPrev', INCLUDE_PREV_OUTCOME);

        if SHIFT_CONTROL
            [nn_corr_shift(c,:,:),nn_sig_shift(c,:,:)] = NNCorrFunction(data1, data2,...
                raster_params, BIN_SIZE, 'shiftControl', true, 'seperateByPrev', INCLUDE_PREV_OUTCOME);
        end


        pop_inx(c)=ii;

    end
end

%%
figure
c=0;


rel_cells = h(1,:)&h(2,:);
rel_cells = 1:length(h);

ave_nb_corr_mult = squeeze(mean(nb_corr1.*nb_corr2,2,"omitnan"));
ave_nn_corr = squeeze(mean(nn_corr,2,"omitnan"));
for ii=1:size(POPULATIONS,1)
    c = c+1;

    subplot(size(POPULATIONS,1),2,c); hold on
    inx = find(pop_inx==ii & rel_cells);
    ave = squeeze(mean(ave_nb_corr_mult(inx,:),"omitnan"));
    sem = squeeze(nanSEM(ave_nb_corr_mult(inx,:)));
    errorbar(ts,ave,sem)
    ave = squeeze(mean((ave_nn_corr(inx,:)),"omitnan"));
    sem = squeeze(nanSEM(ave_nn_corr(inx,:)));
    errorbar(ts,ave,sem)
    xlabel(['Time from ' raster_params.align_to]); ylabel('ave corr')
    title([POPULATIONS{ii,1} ' and ' POPULATIONS{ii,2} ', n = '...
        num2str(length(inx))])
    yline(0)

    legend('nb*nb','nn','0')

    c = c+1;

    subplot(size(POPULATIONS,1),2,c); hold on
    
    corr_mat = corr(ave_nb_corr_mult(inx,:),ave_nn_corr(inx,:),rows="pairwise");
    r_nb_nn = diag(corr_mat);
    ave = mean(r_nb_nn,2,"omitnan");
    sem = nanSEM(r_nb_nn,2);
    errorbar(ts,ave,sem)
    xlabel(['Time from ' raster_params.align_to]);
    ylabel('Corrlation of nb*nb with nn')
    title([POPULATIONS(ii,1) ' and ' POPULATIONS(ii,2)])
    yline(0)

    ylim ([-1 1])

end

%%


figure
for ii=1:size(POPULATIONS,1)

    subplot(size(POPULATIONS,1),1,ii); hold on
    inx = find(pop_inx==ii);
    ave = squeeze(mean(nn_sig(inx,:,:),[1,2],"omitnan"));
    plot(ts,ave)
    xlabel(['Time from ' raster_params.align_to]); ylabel('Frac sig')
    title([POPULATIONS(ii,1) ' and ' POPULATIONS(ii,2)])
    yline(0.05)
    ylim([0 0.5])

end


figure
inx = find(pop_inx==3);

for ii=1:length(ts)
    subplot(length(ts)/2,2,ii)
    scatter(ave_nn_corr(inx,ii),ave_nb_corr_mult(inx,ii))
end

%% Shift control

figure
c=0;
NUM_COL = 2;

rel_cells = h(1,:)&h(2,:);
rel_cells = 1:length(h);

ave_nb_corr_mult = squeeze(mean(nb_corr1.*nb_corr2,2,"omitnan"));
ave_nn_corr = squeeze(mean(nn_corr,2,"omitnan"));

ave_nb_corr_mult_shift = squeeze(mean(nb_corr1_shift.*nb_corr2_shift,2,"omitnan"));
ave_nn_corr_shift = squeeze(mean(nn_corr_shift,2,"omitnan"));

for ii=1:size(POPULATIONS,1)

    inx = find(pop_inx==ii & rel_cells);

    c = c+1;

    subplot(size(POPULATIONS,1),NUM_COL,c); hold on

    ave = squeeze(mean(ave_nb_corr_mult(inx,:),"omitnan"));
    sem = squeeze(nanSEM(ave_nb_corr_mult(inx,:)));
    errorbar(ts,ave,sem,'r')
    ave = squeeze(mean((ave_nn_corr(inx,:)),"omitnan"));
    sem = squeeze(nanSEM(ave_nn_corr(inx,:)));
    errorbar(ts,ave,sem','b')

    ave = squeeze(mean(ave_nb_corr_mult_shift(inx,:),"omitnan"));
    sem = squeeze(nanSEM(ave_nb_corr_mult_shift(inx,:)));
    errorbar(ts,ave,sem,'r--')
    ave = squeeze(mean((ave_nn_corr_shift(inx,:)),"omitnan"));
    sem = squeeze(nanSEM(ave_nn_corr_shift(inx,:)));
    errorbar(ts,ave,sem','b--')

    xlabel(['Time from ' raster_params.align_to]); ylabel('ave corr')
    title([POPULATIONS(ii,1) ' and ' POPULATIONS(ii,2)])
    yline(0)

    legend('nb*nb','nn','nb*nb shift',' nn shift','0')

    c = c+1;

    subplot(size(POPULATIONS,1),NUM_COL,c); hold on

    r_nb_nn = corr(ave_nb_corr_mult(inx,:),nn_corr(inx,:),rows="pairwise");
    ave = mean(r_nb_nn,2,"omitnan");
    sem = nanSEM(r_nb_nn,2);
    errorbar(ts,ave,sem,'k')

    r_nb_nn = corr(ave_nb_corr_mult_shift(inx,:),nn_corr_shift(inx,:),rows="pairwise");
    ave = mean(r_nb_nn,2,"omitnan");
    sem = nanSEM(r_nb_nn,2);
    errorbar(ts,ave,sem,'k--')

    xlabel(['Time from ' raster_params.align_to]);
    ylabel('Corrlation of nb*nb with nn')
    title([POPULATIONS(ii,1) ' and ' POPULATIONS(ii,2)])
    yline(0)
    legend('real','shift')
    ylim ([-1 1])
end

%% significance of nn-nb*nb correlations in time
figure; hold on
cols = {'r','k','b'};
for ii=1:size(POPULATIONS,1)
    inx = find(pop_inx==ii);
    plot(ts,ave_nn_corr(inx,:),[cols{ii} '*'])

end

legend({"bg-bg",'bg-ver','ver-ver'})
xlabel(['time from ' raster_params.align_to])