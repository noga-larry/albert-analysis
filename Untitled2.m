    
    hfunc = @(A,B) any(abs(A-(B*b_1(1)+b_0(1)))>5);
    
    H = cellfun(hfunc,maestroH,extendedH,'Un',0);
    
     vfunc = @(A,B) any(abs(A-(B*b_1(2)+b_0(2)))>5);
    
    V = cellfun(vfunc,maestroV,extendedV,'Un',0);
    
    ind = find([H{:}] | [V{:}] );
    
    
    for j=1:length(ind)
    
        subplot(1,2,1)
    plot(maestroH{ind(j)}); hold on
    plot((extendedH{ind(j)}*b_1(1)+b_0(1))); hold off
    
            subplot(1,2,2)
    plot(maestroV{ind(j)}); hold on
    plot((extendedV{ind(j)}*b_1(2)+b_0(2))); hold off
    
    
    suptitle(data.trials(ind(j)).maestro_name)
    pause
    end
    
