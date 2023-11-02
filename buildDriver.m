function [valuesDr] = buildDriver(driverSettings)

if ~isfield(driverSettings,'sweepType')
    warning('Missing sweep type for drivers, default will be used, default value is ''lin'' ')
    driverSettings.sweepType = 'lin';
end

switch(driverSettings.sweepType)
    case 'lin'
        variation = linspace(driverSettings.maxVoltage, -driverSettings.maxVoltage, driverSettings.NsweepSteps); % from smaller to bigger value
        not_variation = linspace(-driverSettings.maxVoltage, driverSettings.maxVoltage, driverSettings.NsweepSteps); %from bigger to smaller value
    case 'log'
        half_pos_variation = driverSettings.maxVoltage*logspace(-2, 0, driverSettings.NsweepSteps/2); % generates NsweepSteps/2 points between decades 10^-2 and 10^0. 0.01 1
        overturned_half_pos_variation = driverSettings.maxVoltage*logspace(0, -2, driverSettings.NsweepSteps/2);                                                       %1 0.01
        
        % Add a central '0' for compliance with odd NsweepSteps 
        if mod(driverSettings.NsweepSteps,2)
            variation = [ overturned_half_pos_variation 0 -half_pos_variation];% from smaller to bigger value
            not_variation = [ -overturned_half_pos_variation 0 half_pos_variation];%from bigger to smaller value
        else
            variation = [ overturned_half_pos_variation -half_pos_variation];% from smaller to bigger value
            not_variation = [ -overturned_half_pos_variation half_pos_variation];%from bigger to smaller value
        end
    otherwise
        warning('Sweep type for drivers not recognized, default will be used, default value is ''lin'' ')
        variation = linspace(driverSettings.maxVoltage, -driverSettings.maxVoltage, driverSettings.NsweepSteps);
        not_variation = linspace(-driverSettings.maxVoltage, driverSettings.maxVoltage, driverSettings.NsweepSteps);
end

Ndrivers = driverSettings.Ninputs;

D_sweep = repelem(variation, driverSettings.cycleLength); % each element of variation is repeated cycleLength times
D_not_sweep = repelem(not_variation, driverSettings.cycleLength); % each element of not_variation is repeated cycleLength times
D_one = -driverSettings.maxVoltage * ones(1, length(D_sweep));
D_zero = driverSettings.maxVoltage * ones(1, length(D_sweep));

% D0 = driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset
% D1 = -driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset

[~, Ncomb] = size(driverSettings.driverModes);   % the number of columns of driverModes tells the number of driver values' combinations 
% fixed_value_length = (driverSettings.NsweepSteps*Ncomb + driverSettings.phasesRepetition - 1)*driverSettings.cycleLength + (driverSettings.NclockRegions - 1)*driverSettings.clockStep;

% creating two temporary structures from which we will copy the values in valuesDr
% tmp_valuesDr = cell(Ndrivers,fixed_value_length);
% tmp_valuesDr_neg = tmp_valuesDr;

empty_pipe = (driverSettings.phasesRepetition)*driverSettings.cycleLength; %length of the values to insert to empty the pipe and make the last input to propagate till the end of the circuit
Dr_tot = zeros(Ndrivers,length(D_sweep)*Ncomb + empty_pipe);
valuesDr = cell(Ndrivers+Ndrivers*driverSettings.doubleMolDriver,length(Dr_tot)+1); % + 1 for the input name, times 2 if doubleMolDriver

for nDr = 1:Ndrivers     %for each input branch
    for jj = 0:Ncomb-1     % for each combination value
        currentArrayElements = (jj*length(D_sweep) + 1):(length(D_sweep)+jj*length(D_sweep));
        switch(driverSettings.driverModes{nDr,jj+1})
            case '0'
                Dr_tot(currentArrayElements) = D_zero;
            case '1'
                Dr_tot(currentArrayElements) = D_one;
            case 'sweep'
                Dr_tot(currentArrayElements) = D_sweep;
            case 'not_sweep'
                Dr_tot(currentArrayElements) = D_not_sweep;
        end
    end

    % % adding flap_array to consider the repetition of phases
    % if (driverSettings.phasesRepetition > 1)
    %     flap_array = D_tot(end)*ones( 1, (driverSettings.phasesRepetition - 1)*driverSettings.cycleLength );
    %     D_tot = horzcat(D_tot,flap_array);
    % end
    
    % filling elements for the empty pipe phase looking the last value of the combinations
    if strcmp(driverSettings.driverModes{nDr,end},'sweep') || strcmp(driverSettings.driverModes{nDr,end},'1')
        Dr_tot(currentArrayElements(end)+1:end) = -driverSettings.maxVoltage * ones(1,empty_pipe);
    else % not_sweep or '0'
        Dr_tot(currentArrayElements(end)+1:end) = driverSettings.maxVoltage * ones(1,empty_pipe);
    end

    valuesDr{nDr,1} = driverSettings.driverNames{nDr}; %write dr name in row ii and column 1
    valuesDr(nDr,2:end) = [num2cell(Dr_tot)];
    if driverSettings.doubleMolDriver
         valuesDr{nDr+Ndrivers,1} = [driverSettings.driverNames{nDr} '_c'];  %write dr_c name in row ii+Ndrives and column 1, so we obtain Dr1,Dr2,..,DrN,Dr1_c,Dr2_c,..,DrN_c
         valuesDr(nDr+Ndrivers,2:end) = [num2cell(-Dr_tot)];
    end

    % D_tot_neg = -D_tot;
    % D_tot = num2cell(D_tot);
    % D_tot_neg = num2cell(D_tot_neg);
    % [tmp_valuesDr{j,:}] = D_tot{:};
    % [tmp_valuesDr_neg{j,:}] = D_tot_neg{:};
end


%initialize valuesDr cell array
% if driverSettings.doubleMolDriver
%     valuesDr = cell(Ndrivers*2,fixed_value_length+1); %nrows = number of driver times 2 because the doubleDriverMode,ncol = length of the input values + 1 for the input name
% else
%     valuesDr = cell(Ndrivers,fixed_value_length+1); % not in doubleDriverMode, so just one row per input
% end

% for ii = 1:Ndrivers
%      name = driverSettings.driverNames{ii};
%      valuesDr{ii,1} = name; %write dr name in row ii and column 1
% 
%      if driverSettings.doubleMolDriver
%          name_c = [name '_c'];
%          valuesDr{ii+Ndrivers,1} = name_c;  %write dr_c name in row ii+Ndrives and column 1, so we obtain Dr1,Dr2,..,DrN,Dr1_c,Dr2_c,..,DrN_c
%      end
% 
%      [valuesDr{ii,2:end}] = tmp_valuesDr{ii,:};
% 
%      if driverSettings.doubleMolDriver 
%          [valuesDr{ii+Ndrivers,2:end}] = tmp_valuesDr_neg{ii,:};
%      end
% 
% end