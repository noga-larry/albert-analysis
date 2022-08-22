clear 
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

req_params.grade = 7;
req_params.cell_type = {'PC ss','CRB','SNR','BG msn'};
%req_params.cell_type = {'SNR'};
req_params.task = 'pursuit_8_dir_75and25|saccade_8_dir_75and25';
req_params.task = 'pursuit_8_dir_75and25';
%req_params.task = 'rwd_direction_tuning';
req_params.num_trials = 100;
req_params.remove_question_marks = 1;
%req_params.ID = [4006,4012,4055,4062,4063,4064,4068,4069,4077,4078,4079,4081,4086,4093,4110,4111,4114,4153,4156,4164,4178,4179,4184,4198,4212,4223,4235,4395,4396,4397,4400,4419,4425,4425,4426,4426,4426,4427,4427,4428,4428,4429,4435,4446,4447,4479,4506,4506,4510,4514,4526,4542,4998,4999,5000,5010,5013,5017,5018,5020,5021,5022,5024,5025,5026,5030,5030,5031,5031,5032,5033,5035,5036,5040,5042,5043,5049,5051,5052,5059,5060,5061,5063,5065,5066,5067,5068,5070,5071,5072,5073,5075,5077,5085,5088,5089,5091,5092,5093,5095,5097,5098,5101,5102,5103,5104,5105,5112,5116,5117,5159,5247,5251,5366,5367,5376,5377,5392,5418,5418,5418,5418,5440,5442,5462,5463,5466,5467]
req_params.remove_repeats = true;
%req_params.ID =4209;
 
EPOCH =  'targetMovementOnset'; 
lines = findLinesInDB (task_info, req_params);
cells = findPathsToCells (supPath,task_info,lines);

list = [];
for ii = 1:length(cells)
    
    data = importdata(cells{ii});
    cellType{ii} = task_info(lines(ii)).cell_type;
    cellID(ii) = data.info.cell_ID;
    
    [effects(ii), tbl] = effectSizeInEpoch(data,EPOCH); 
    time_significance(ii) = tbl{2,end}<0.05; %time
    
    task_info(lines(ii)).time_sig_motion = time_significance(ii);
end
save ([task_DB_path '.mat'],'task_info')


%%
N = length(req_params.cell_type);
figure; 
for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    
    if isempty(indType)
        continue
    end
    disp('Frac cell with insignificant time effect:')    
    disp ([req_params.cell_type{i} ': ' num2str(mean(time_significance(indType)))...
        ', n = ' num2str(sum(time_significance(indType)))]) 
    
    subplot(3,N,i)
    scatter([effects(indType).time],[effects(indType).reward],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).reward]);
    xlabel('time')
    ylabel('reward+time*reward')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
        
    subplot(3,N,i+N)
    scatter([effects(indType).time],[effects(indType).direction],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).time],[effects(indType).direction]);
    xlabel('time')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
    
    subplot(3,N,i+2*N)
    scatter([effects(indType).reward],[effects(indType).direction],'filled','k'); hold on
    p = bootstrapTTest([effects(indType).direction],[effects(indType).reward]);
    xlabel('reward+time*reward')
    ylabel('direction+time*direcion')
    equalAxis()
    refline(1,0)
    title(req_params.cell_type{i})
    subtitle(['p = ' num2str(p) ',n = ' num2str(length(indType))])
    
end

%%
figure;


bins = linspace(-0.2,1,100);
f = fields(effects);

for j = 1:length(f)
    for i = 1:length(req_params.cell_type)
        
        indType = find(strcmp(req_params.cell_type{i}, cellType));
        subplot(length(f),1,j)
        plotHistForFC([effects(indType).(f{j})],bins); hold on
    end
    
    title(f{j})
    legend(req_params.cell_type)

end

legend(req_params.cell_type)
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


%% tests

x = [effects.direction];

p = bootstraspWelchANOVA(x', cellType');

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x(find(strcmp('BG msn', cellType))))


x = [effects.direction];

for i = 1:length(req_params.cell_type)
    
    indType = find(strcmp(req_params.cell_type{i}, cellType));
    p = bootstrapTTest(x(indType));
    disp([req_params.cell_type{i} ': p = ' num2str(p) ', n = ' num2str(length(indType)) ] )
    
end

%
x = [effects.direction];

p = bootstraspWelchANOVA(x(time_significance)', cellType(time_significance)')

p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('PC ss', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('CRB', cellType))))
p = bootstraspWelchTTest(x(find(time_significance & strcmp('SNR', cellType))),...
    x(find(time_significance & strcmp('BG msn', cellType))))


% floc
load('floc data motion.mat')

x = [effects.reward];
x_floc = [floc_eff.direction];
p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('CRB', floc_type))))

p = bootstraspWelchTTest(x(find(strcmp('SNR', cellType))),...
    x_floc(find(strcmp('PC ss', floc_type))))

