function [stack_phase] = buildClock(NclockRegions,NsweepSteps,phasesRepetition,pReset,pCycle,NdriverComb)

    [~,Ncomb] = size(NdriverComb);
    filler = repmat(pReset,1,(phasesRepetition)*NclockRegions); %for emptying the pipe
    completeCycle = [repmat(pCycle,1,NsweepSteps*Ncomb) filler];
    stack_phase = zeros(NclockRegions,length(completeCycle));
    
    for ii = 1:NclockRegions
        stack_phase(ii,:) = circshift(completeCycle,length(pReset)*(ii-1));
    end

end