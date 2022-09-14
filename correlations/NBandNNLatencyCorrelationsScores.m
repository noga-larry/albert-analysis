clear; clc
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

warning('off')
POPULATIONS = {'BG msn|SNR','BG msn|SNR';...
    'BG msn|SNR','PC ss|CRB';...
    'PC ss|CRB','PC ss|CRB'};
BIN_SIZE = 100;
DIRECTIONS = 0:45:315;
PROBABILIES = [25,75];

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

        nb_corr1(c,:) = LatencyNBCorrScores(data1, PROBABILIES, DIRECTIONS, raster_params,...
            BIN_SIZE);

        nb_corr2(c,:) = LatencyNBCorrScores(data2, PROBABILIES, DIRECTIONS, raster_params,...
            BIN_SIZE);

        [data1,data2] = reduceToSharedTrials(data1,data2);


        h(1,c) = task_info(cur_pairs(j).cell1).time_sig_motion;
        h(2,c) = task_info(cur_pairs(j).cell2).time_sig_motion;

        boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];

        [~,match_p] = getProbabilities(data1);

        for p = 1:length(PROBABILIES)
            inx = find(match_p==PROBABILIES(p) & ~ boolFail);
            psth1 = getSTpsth(data1,inx,raster_params);
            psth2 = getSTpsth(data2,inx,raster_params);

            % shift control
            %psth1 = psth1(1:end-1,:); psth2 = psth2(2:end,:);

            [~,score,~,~] = pca(psth1);
            neuron1 = score(:,1);

            [~,score,~,~] = pca(psth2);
            neuron2 = score(:,1);

            [nn_corr(c,p),nn_sig(c,p) ] = corr(neuron1,neuron2);

        end
        pop_inx(c)=ii;

    end
end

%%
figure
c=0;
tmp = nb_corr1.*nb_corr2;
ave_nb_corr_mult = nb_corr1.*nb_corr2;
for ii=1:size(POPULATIONS,1)
    c = c+1;

    subplot(size(POPULATIONS,1),1,c); hold on
    inx = find(pop_inx==ii);
    scatter(ave_nb_corr_mult(inx,:),nn_corr(inx,:))
    p_val = signrank(ave_nb_corr_mult(inx),ave_nn_corr(inx));
    axis square
    axis([-0.8 0.8 -0.8 0.8])
    refline(1,0)
    xlabel(['nb*nb']); ylabel('nn')
    title([POPULATIONS{ii,1} ' and ' POPULATIONS{ii,2} ', Signrank: p = ' num2str(p_val)])

   
end



%%

function [nb_corr,nb_significance] = LatencyNBCorrScores(data, probabilities, directions,raster_params, bin_sz)

[~,match_p] = getProbabilities (data);
boolFail = [data.trials.fail] | ~[data.trials.previous_completed];

for p=1:length(probabilities)

    inx_prob = find(match_p==probabilities(p) & ~ boolFail);
    [~,match_d] = getDirections (data,inx_prob,'omitNonIndexed',true);

    latencies = saccadeRTs(data,inx_prob);

    psths= getSTpsth(data,inx_prob,raster_params);

    for d = 1:length(directions)
        inx = find(match_d==directions(d));
        latencies(inx) = latencies(inx) - mean(latencies(inx),"omitnan");
    end

    [~,score,~,~] = pca(psths);
    neuron = score(:,1);

    % shuffle
    %     latencies = latencies(1:end-1);
    %     psths = psths(2:end,:);

    [nb_corr(p),nb_significance(p)] = corr(neuron,latencies');

end
end