clear 
[task_info,supPath] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
%req_params.task = 'rwd_direction_tuning';
req_params.num_trials = 70;
req_params.remove_question_marks = 1;
%req_params.ID = [4006,4012,4055,4062,4063,4064,4068,4069,4077,4078,4079,4081,4086,4093,4110,4111,4114,4153,4156,4164,4178,4179,4184,4198,4212,4223,4235,4395,4396,4397,4400,4419,4425,4425,4426,4426,4426,4427,4427,4428,4428,4429,4435,4446,4447,4479,4506,4506,4510,4514,4526,4542,4998,4999,5000,5010,5013,5017,5018,5020,5021,5022,5024,5025,5026,5030,5030,5031,5031,5032,5033,5035,5036,5040,5042,5043,5049,5051,5052,5059,5060,5061,5063,5065,5066,5067,5068,5070,5071,5072,5073,5075,5077,5085,5088,5089,5091,5092,5093,5095,5097,5098,5101,5102,5103,5104,5105,5112,5116,5117,5159,5247,5251,5366,5367,5376,5377,5392,5418,5418,5418,5418,5440,5442,5462,5463,5466,5467]
req_params.remove_repeats = false;
req_params.ID = 4797
 
EPOCH =  'targetMovementOnset'; 
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);


list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    effects(ii) = effectSizeInEpoch(data,EPOCH);    
   
end


%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    subplot(3,N,i)
    scatter([effects(indType).time],[effects(indType).reward],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).reward]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).time],[effects(indType).direction]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward],[effects(indType).direction],'filled','k'); hold on
    p = signrank([effects(indType).direction],[effects(indType).reward]);
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p)])
    
end

%%
figure;


bins = linspace(-0.2,1,50);
f = fields(effects);

for j = 1:length(f)
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        subplot(length(f),1,j)
        plotHistForFC([effects(indType).(f{j})],bins); hold on
    end
    title(f{j})
end

legend(req_params.cell_type)
sgtitle('Cue','Interpreter', 'none');
sgtitle('Motion','Interpreter', 'none');
%%

f = figure; f.Position = [10 80 700 500];
bins = -0.3:0.05:1;

overallExplained = omegaR+omegaD+omegaT;
p = ranksum(overallExplained(indType),overallExplained(~indType))
plotHistForFC(overallExplained(indType),bins,'g'); hold on
plotHistForFC(overallExplained(~indType),bins,'r'); hold on
legend('SS', 'CRB')
title(['Over all: ranksum: P = ' num2str(p) ', n_{ss} = ' num2str(sum(indType)) ', n_{crb} = ' num2str(sum(~indType))])


%% comparisoms fron input-output figure
figure

effect_size = [effects.direction];


x1 = subplot(2,2,1); hold on
x2 = subplot(2,2,2); hold on
x3 = subplot(2,2,3); hold on
x4 = subplot(2,2,4); hold on

indType = find(strcmp('SNR', cellType));
plot(x1,3,effect_size(indType),'ob')
ci = bootci(2000,@median,effect_size(indType))
errorbar(x2,3,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

indType = find(strcmp('BG msn', cellType));
plot(x1,4,effect_size(indType),'or')
ci = bootci(2000,@median,effect_size(indType))-median(effect_size(indType))
errorbar(x2,4,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

p = ranksum(effect_size(find(strcmp('SNR', cellType))),effect_size(find(strcmp('BG msn', cellType))))
title(x2,['p = ' num2str(p) ', n_{SNR} = ' num2str(sum(strcmp('SNR', cellType))) ...
    ', n_{msn} = ,' num2str(sum(strcmp('BG msn', cellType)))])

%%
indType = find(strcmp('PC ss', cellType));
plot(x3,3,effect_size(indType),'ob')
ci = bootci(2000,@median,effect_size(indType)) - median(effect_size(indType))
errorbar(x4,3,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)


indType = find(strcmp('CRB', cellType));
plot(x3,4,effect_size(indType),'or')
ci = bootci(2000,@median,effect_size(indType))
errorbar(x4,4,median(effect_size(indType)),ci(1),ci(2),'LineWidth',4)

p = ranksum(effect_size(find(strcmp('PC ss', cellType))),effect_size(find(strcmp('CRB', cellType))))
title(['p = ' num2str(p) ', n_{ss} = ' num2str(sum(strcmp('PC ss', cellType))) ...
    ', n_{crb} = ,' num2str(sum(strcmp('CRB', cellType)))])
%%
input_output = cellfun(@(x)~isempty(x),regexp('PC ss|SNR',cellType)) 
bg_crb = cellfun(@(x)~isempty(x),regexp('PC ss|CRB',cellType)) 
Data = [effect_size',input_output',bg_crb']
out = SRH_test(Data,'area','input_output')
%% CV and
raster_params.align_to = 'cue';
raster_params.time_before = 200;
raster_params.time_after = 600;
raster_params.smoothing_margins = 0;
req_params.num_trials = 50;

for ii = 1:length(cells)
    data = importdata(cells{ii});
    
    cellType{ii} = data.info.cell_type;
    
    boolFail = [data.trials.fail] | ~[data.trials.previous_completed];
    
    raster = getRaster(data,find(~boolFail),raster_params);
    FR(ii) = mean(mean(raster)*1000);
    CV2(ii) = nanmean(getCV2(data,find(~boolFail),raster_params));
    CV(ii) = nanmean(getCV(data,find(~boolFail),raster_params));
end

figure; 
scatter(FR(indType),overallExplained(indType),'k'); hold on
scatter(FR(~indType),overallExplained(~indType),'m'); hold on
legend('SS', 'CRB')

xlabel('FR')
ylabel('Sum of effects')
[r1,p1] = corr(FR(indType)',overallExplained(indType)','type','Spearman')
[r2,p2] = corr(FR(~indType)',overallExplained(~indType)','type','Spearman')
title(['SS : r = ' num2str(r1) ', ' num2str(p1) ', CRB : r = ' num2str(r2) ', ' num2str(p2)])
