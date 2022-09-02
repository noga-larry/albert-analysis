clear
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

POPULATIONS = {'BG|SNR','BG|SNR';...
    'BG|SNR','PC ss|CRB';...
    'PC ss|CRB','PC ss|CRB'};

PROBABILITIES = [25,75];
DIRECTIONS = 0:45:315;
EPOCH = 'targetMovementOnset';


raster_params.time_before = 200;
raster_params.time_after = 800;
raster_params.smoothing_margins = 200;
raster_params.SD=15;
raster_params.align_to = EPOCH;


req_params.grade = 7;
req_params.ID = 4000:6000;
req_params.remove_question_marks = false;
req_params.num_trials = 120;
req_params.remove_repeats = false;
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';

for ii=1:size(POPULATIONS,1)
    req_params.cell_type = POPULATIONS{ii,1};
    lines1 = findLinesInDB (task_info, req_params);
    req_params.cell_type = POPULATIONS{ii,2};
    lines2 = findLinesInDB (task_info, req_params);
    pairs{ii} = findPairs(task_info,lines1,lines2,...
        req_params.num_trials);
end

c=0;
for ii=1:length(pairs)

    cur_pairs = pairs{ii};

    for j=1:length(cur_pairs)
        cells = findPathsToCells (supPath,task_info,[cur_pairs(j).cell1,cur_pairs(j).cell2]);
        data1 = importdata(cells{1});
        data2 = importdata(cells{2});
        [data1,data2] = reduceToSharedTrials(data1,data2);

        [~,match_p] = getProbabilities (data1);
        [~,match_d] = getDirections (data1);

        boolFail = [data1.trials.fail] | ~[data1.trials.previous_completed];


        switch EPOCH
            case 'cue'
                inx_cell = cell(1,length(PROBABILITIES));
                for j=1:length(PROBABILITIES)
                    inx_cell{j} = find (match_p == PROBABILITIES(j) & (~boolFail));
                end
            case 'targetMovementOnset'
                inx_cell = cell(1,length(PROBABILITIES)*length(DIRECTIONS));
                c_inx = 0;
                for j=1:length(PROBABILITIES)
                    for k=1:length(DIRECTIONS)
                        c_inx = c_inx+1;
                        inx_cell{c_inx} = find (match_d == DIRECTIONS(k) & ...
                            match_p == PROBABILITIES(j) & (~boolFail));
                    end
                end
        end

        for j=1:length(inx_cell)
            
            c=c+1;

            ind = inx_cell{j};

            psths1 = getSTpsth(data1,ind,raster_params);
            psths2 = getSTpsth(data2,ind,raster_params);

            ave_psth1 = mean(psths1);
            ave_psth2 = mean(psths2);

            ave_psth_corr(c) = corr(ave_psth1',ave_psth2');
            tmp = corr(psths1',psths2'); tmp(find(eye(size(tmp))))=nan;
            gil_corr(c) = mean(corr(psths1',psths2'),"all","omitnan");
            noise_corr(c) = corr(mean(psths1,2),mean(psths2,2));

            pop_inx(c)=ii;
        end
    end
end


%%
figure; subplot(2,1,1)
gscatter(ave_psth_corr,noise_corr,pop_inx)
xlabel('PSTH corr'); ylabel('Noise corr');
leg_names = {'BG-BG','BG-Ver','Ver-Ver'};
for ii=1:size(POPULATIONS,1)
    inx = find(pop_inx==ii);
    r = corr(ave_psth_corr(inx)',noise_corr(inx)','rows','pairwise','type','Spearman');
    n = length(inx);
    leg{ii} = [leg_names{ii} ': r = ' num2str(r) ',n = ' num2str(n)];
end
legend(leg)


subplot(2,1,2)
gscatter(gil_corr,noise_corr,pop_inx)
xlabel('Gil corr'); ylabel('Noise corr');
leg_names = {'BG-BG','BG-Ver','Ver-Ver'};
for ii=1:size(POPULATIONS,1)
    inx = find(pop_inx==ii);
    r = corr(gil_corr(inx)',noise_corr(inx)','rows','pairwise');
    leg{ii} = [leg_names{ii} ': r = ' num2str(r)];
end
legend(leg)

%%

%% 
EDGE = 0.1;

figure
remove_inx = find(gil_corr<-0.1 | gil_corr>0.1);
gil_corr_trim =  gil_corr; gil_corr_trim(remove_inx)=[];
noise_corr_trim = noise_corr; noise_corr_trim(remove_inx)=[];
pop_inx_trim = pop_inx;pop_inx_trim(remove_inx)=[];

gscatter(gil_corr_trim,noise_corr_trim,pop_inx_trim)
xlabel('PSTH corr'); ylabel('Noise corr');
leg_names = {'BG-BG','BG-Ver','Ver-Ver'};
for ii=1:size(POPULATIONS,1)
    inx = find(pop_inx_trim==ii);
    r(ii) = corr(gil_corr_trim(inx)',noise_corr_trim(inx)','rows','pairwise','type','Spearman');
    n(ii) = length(inx)
    leg{ii} = [leg_names{ii} ': r = ' num2str(r(ii))];
end
legend(leg)

corr_rtest(r(1),r(2),n(1),n(2))
corr_rtest(r(3),r(2),n(2),n(3))


%% matching

inx_between = find(pop_inx==2);
inx_within = find(pop_inx==1);
between_signal_corr = gil_corr(inx_between);
within_signal_corr = gil_corr(inx_within);
between_noise_corr = noise_corr(inx_between);
within_noise_corr = noise_corr(inx_within);

signal_match = nan(1,length(inx_between));
noise_match = nan(1,length(inx_between));


for ii = 1:length(inx_between)
    dists = abs(between_signal_corr(ii)-within_signal_corr);
    [~,ind_match] = min(dists);
    signal_match(ii) = within_signal_corr(ind_match);
    noise_match(ii) = within_noise_corr(ind_match);
end

figure;
subplot(2,1,1);
scatter(between_signal_corr,signal_match);
axis equal; refline(1,0);
r = corr(between_signal_corr',signal_match',"rows",'pairwise');
xlabel('between'); ylabel('match within')
title(['signal corr, r = ' num2str(r)])

subplot(2,1,2);
scatter(between_noise_corr,noise_match);
axis equal; refline(1,0);
p = signrank(between_noise_corr,noise_match);
xlabel('between'); ylabel('match within')
title(['noise corr, signrank p = ' num2str(p)])