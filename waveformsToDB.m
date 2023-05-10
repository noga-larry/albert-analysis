
clear
[task_info,supPath,~,task_DB_path] = loadDBAndSpecifyDataPaths('Vermis');

WAVEFORMS_PATH = [supPath '\waveforms'];
WINDOW_SIZE_BEFORE_PEAK = 40;
WINDOW_SIZE_AFTER_PEAK = 40;
BASELINE = 10; % 10 sample from min point
Fs = 40; % kHz
PLOT_CELL = 0;


req_params = reqParamsEffectSize("both");
req_params.cell_type = {'PC ss','CRB'};
req_params.remove_question_marks = false;

lines = findLinesInDB (task_info, req_params);
paths = findPathsToCells (supPath,task_info,lines);

c=0;
for ii = 1:length(paths)
    
    file_name = [WAVEFORMS_PATH '\ID' ...
        num2str(task_info(lines(ii)).cell_ID) ...
        '_f' num2str(task_info(lines(ii)).fb_after_sort)...
        '_' num2str(task_info(lines(ii)).fe_after_sort) '.mat'];
    
    if ~(exist(file_name,'file')==2)
        continue
    end
    
    waveforms = importdata(file_name);
        
    if size(waveforms.wave,1)<20
        continue
    end
    
    c=c+1;
    % align to peak
    [~,peaks] = min(waveforms.wave');
    
    aligned_waveforms = nan(size(waveforms.wave,1),2*WINDOW_SIZE_BEFORE_PEAK);
    for j = 1:size(aligned_waveforms,1)
        
        tb = max(1,peaks(j)-WINDOW_SIZE_BEFORE_PEAK);
        te = min(size(waveforms.wave,2),peaks(j)+WINDOW_SIZE_AFTER_PEAK);
        inx = tb:te;
        aligned_waveforms(j,WINDOW_SIZE_BEFORE_PEAK-peaks(j)+inx+1) = waveforms.wave(j,inx);
        
    end
    
    ave = mean(aligned_waveforms,'omitnan');
    [~,t_trough] = min(ave);
    [~,t_peak] = findpeaks(ave(t_trough:end),'NPeaks',1,'SortStr','descend');
    t_peak = t_trough+t_peak-1;
       
    if isempty(t_peak)
        t_peak = length(ave);
    end
    

    if PLOT_CELL
        subplot(2,1,1)
        plot(waveforms.wave(1:20,:)')
        subplot(2,1,2); hold on
        plot(aligned_waveforms(1:20,:)')
        sgtitle([num2str(task_info(lines(ii)).cell_ID) '    ' num2str(task_info(lines(ii)).grade)])
        xline(BASELINE)
        
        plot(ave,'k','LineWidth',2); hold off
                
        xline(t_trough);xline(t_peak)
        pause
        cla
    end
    
    signal = peak2peak(ave);
    noise = mean(std(aligned_waveforms(:,1:BASELINE),"omitnan"),"omitnan");
    snrs(c) = signal/noise;
    grades(c) = task_info(lines(ii)).grade;
    
    task_info(lines(ii)).waveforms_snr = snrs(c);
    waveform_width(c) = 10^3*(t_peak-t_trough)/Fs; %micro sec
    task_info(lines(ii)).waveform_width = waveform_width(c);
    
    peaks(ii) = ave(t_peak);
    trough(ii) = ave(t_trough);
end

save(task_DB_path,'task_info')