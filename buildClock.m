function [stack_phase] = buildClock(NclockRegions,NsweepSteps,phasesRepetition,pReset,pCycle,driverModes)

filler = repmat(pReset,1,(NclockRegions - 1));
Ncomb = size(driverModes);
completeCycle = repmat([repmat(pCycle, 1, NsweepSteps + phasesRepetition - 1) filler ],1,Ncomb(1));
stack_phase = zeros(NclockRegions,length(completeCycle));

for ii = 1:NclockRegions
    stack_phase(ii,:) = circshift(completeCycle,length(pReset)*(ii-1));
end


end