function [stack_phase] = buildClock(settings)

    [~,Ncomb] = size(settings.driverModes);
    filler = repmat(settings.pReset,1,settings.NclockRegions); %for alignment
    completeCycle = [repmat(settings.pCycle,1,settings.NsweepSteps*Ncomb+(settings.phasesRepetition-1)) filler];
    stack_phase = zeros(settings.NclockRegions,length(completeCycle));
    
    for ii = 1:settings.NclockRegions
        stack_phase(ii,:) = circshift(completeCycle,length(settings.pReset)*(ii-1));
    end

end