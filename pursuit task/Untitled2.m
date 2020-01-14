for t=1:length(data.trials)
        raw_speed = sqrt((data.trials(t).extended_hVel).^2 ...
            +(data.trials(t).extended_vVel).^2); hold on
    plot(raw_speed)
end