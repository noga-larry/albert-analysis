clear; clc
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

POPULATIONS = {'BG|SNR','BG|SNR';...
    'BG|SNR','PC ss|CRB';...
    'PC ss|CRB','PC ss|CRB'};

BIN_SIZE_FOR_NOISE = 100;


EPOCH = 'cue';


raster_params.time_before = 199;
raster_params.time_after = 800;
raster_params.smoothing_margins = 200;
raster_params.SD=15;
raster_params.align_to = EPOCH;

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

c=0;
for ii=1:length(pairs)

    cur_pairs = pairs{ii};

    for j=1:length(cur_pairs)

        c=c+1;
        cells = findPathsToCells (supPath,task_info,[cur_pairs(j).cell1,cur_pairs(j).cell2]);
        data1 = importdata(cells{1});
        data2 = importdata(cells{2});
        [data1,data2] = reduceToSharedTrials(data1,data2);
        
        inx_cell = getInxForNoiseCorr(data1,EPOCH);

        for j=1:length(inx_cell)
            
            ind = inx_cell{j};

            psths1 = getSTpsth(data1,ind,raster_params);
            psths2 = getSTpsth(data2,ind,raster_params);

            ave_psth1 = mean(psths1);
            ave_psth2 = mean(psths2);

            ave_psth_corr_per_cond(c,j) = corr(ave_psth1',ave_psth2');
            tmp = corr(psths1',psths2'); tmp(find(eye(size(tmp))))=nan;
            gil_corr_per_cond(c,j) = mean(corr(psths1',psths2'),"all","omitnan");
            psth1_bins = downSampleToBins(psths1,BIN_SIZE_FOR_NOISE);
            psth2_bins = downSampleToBins(psths2,BIN_SIZE_FOR_NOISE);
            tmp = corr(psth1_bins,psth2_bins);
            noise_corr_per_cond(c,j) = mean(diag(tmp),"omitnan");

            pop_inx(c)=ii;
        end
    end
end

ave_psth_corr = mean(ave_psth_corr_per_cond,2);
gil_corr = mean(gil_corr_per_cond,2);
noise_corr = mean(noise_corr_per_cond,2);
%%
BIN_PRC = [0:20:100];
figure; ax1 = subplot(1,2,1); ax2 = subplot(1,2,2); hold on
gscatter(ax1,ave_psth_corr,noise_corr,pop_inx)
xlabel('PSTH corr'); ylabel('Noise corr');
leg_names = {'BG-BG','BG-Ver','Ver-Ver'};


for ii=1:size(POPULATIONS,1)
    inx = find(pop_inx==ii);
    curr_signal_corr = ave_psth_corr(inx);
    curr_noise_corr = noise_corr(inx);
    r = corr(curr_signal_corr,curr_noise_corr,'rows','pairwise','type','Spearman');
    n = length(inx);
    leg{ii} = [leg_names{ii} ': r = ' num2str(r) ',n = ' num2str(n)];


    % bins
     bin_edges = prctile(ave_psth_corr(inx),BIN_PRC);

     for j=1:length(bin_edges)-1
         inx_bin = find(curr_signal_corr>=bin_edges(j) & curr_signal_corr<bin_edges(j+1));
         x_bin(j) = mean(curr_signal_corr(inx_bin),"omitnan"); 
         y_bin(j) = mean(curr_noise_corr(inx_bin),"omitnan");
         sem_bin(j) = nanSEM(curr_noise_corr(inx_bin));

         length(inx_bin)

     end

     errorbar(ax2,x_bin,y_bin,sem_bin)  
end
legend(ax1,leg)
legend(ax2,leg_names)

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

inx_between = find(pop_inx'==2);
inx_within = find(pop_inx'==3);
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
r = corr(between_signal_corr,signal_match',"rows",'pairwise');
xlabel('between'); ylabel('match within')
title(['signal corr, r = ' num2str(r)])

subplot(2,1,2);
scatter(between_noise_corr,noise_match);
axis equal; refline(1,0);
p = signrank(between_noise_corr,noise_match);
xlabel('between'); ylabel('match within')
title(['noise corr, signrank p = ' num2str(p)])

%% seperate by prob 

correlations_cell = {ave_psth_corr_per_cond, noise_corr_per_cond,gil_corr_per_cond};

if strcmp(EPOCH,'targetMovementOnset')
   for j=1:length(correlations_cell)
       correlations_cell{j} = [mean(correlations_cell{j}(:,1:length(DIRECTIONS)),2,"omitnan"),...
           mean(correlations_cell{j}(:,length(DIRECTIONS)+1:end),2,"omitnan")];
   end
end

correlation_names = {'PSTH corr', 'Noise corr', 'Gil corr'};
leg_names = {'BG-BG','BG-Ver','Ver-Ver'};

figure;

for j=1:length(correlations_cell)
    curr_corr = correlations_cell{j};
    subplot(1,3,j)
    gscatter(curr_corr(:,1),curr_corr(:,2),pop_inx)
    xlabel('P=25'); ylabel('P=75');
    for ii=1:size(POPULATIONS,1)
        inx = find(pop_inx==ii);
        p(ii) = signrank(curr_corr(inx,1),curr_corr(inx,2));
        n(ii) = length(inx);
        leg{ii} = [leg_names{ii} ': p = ' num2str(p(ii)) ',n = ' num2str(n(ii))];
    end
    refline(1,0)
    title(correlation_names{j})
    legend(leg)
end