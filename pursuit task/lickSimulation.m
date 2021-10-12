function  [psth] = lickSimulation...
    (data,lickPSTH,window,alignTo,params,ind)

ind_0_in_psth = params.time_before+length(lickPSTH);
psth = zeros(params.time_after+params.time_before+2*length(lickPSTH),1);
counter = 0;
for t=1:length(ind)
    
    eventTimes = trialLickEvents(alignTo,data.trials(ind(t)),'full')...
        -data.trials(ind(t)).rwd_time_in_extended;
    releventEventTimes =  eventTimes((eventTimes > -ind_0_in_psth) &...
        (eventTimes <= length(psth)-ind_0_in_psth));
    for i=1:length(releventEventTimes)
        embededAddition = zeros(size(psth));
        inx = ind_0_in_psth+releventEventTimes(i)+window;
        inxToEmbed = inx(inx<length(embededAddition) & inx>0);
        lickPSTHToEmbed = lickPSTH(inx<length(embededAddition) & inx>0);
        embededAddition(inxToEmbed)= lickPSTHToEmbed;
        psth = psth + embededAddition;
        counter = counter+1; 
    end
end

cutWindow = -params.time_before:params.time_after;
psth = psth/counter;
psth = psth(ind_0_in_psth+cutWindow);
    

end
