function [stack_phase] = buildClock(NclockRegions,NsweepSteps,phasesRepetition,pReset,pCycle,driverModes)

    size_modes = size(driverModes);
    Ncomb = size_modes(1);
    filler = repmat(pReset,1,(NclockRegions - 1));
    completeCycle = [repmat(pCycle,1,NsweepSteps*Ncomb + phasesRepetition - 1) filler];
    stack_phase = zeros(NclockRegions,length(completeCycle));
    
    for ii = 1:NclockRegions
        stack_phase(ii,:) = circshift(completeCycle,length(pReset)*(ii-1));
    end

end