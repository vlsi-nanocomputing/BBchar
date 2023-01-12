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

D = repelem(variation, driverSettings.cycleLength); % each element of variation is repeated cycleLength times
not_D = repelem(not_variation, driverSettings.cycleLength); % each element of not_variation is repeated cycleLength times

% Add same values to D and not_D to complain with pipeline
if (driverSettings.phasesRepetition > 1)
    flap_array_D = D(end)*ones( 1, (driverSettings.phasesRepetition - 1)*driverSettings.cycleLength );
    flap_array_not_D = not_D(end)*ones(1,(driverSettings.phasesRepetition - 1)*driverSettings.cycleLength);
    D = [D flap_array_D];
    not_D = [not_D flap_array_not_D];
end

D0 = driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset
D1 = -driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset

% The length of a fixed value driver must comply with:
% - Nsteps decide the number of values to send in input, each of them require a pCycle
% - If there is phase repetition, must be considered also (phasesRepetition-1)*pCycle clock cycles considering the latency
% - (NclockRegions-1)*clockStep considers N pReset cycle to complain with the stack_phase

Ncomb = size(driverSettings.driverModes);  %number of combination in the matrix of driver values
fixed_value_length = (driverSettings.NsweepSteps + driverSettings.phasesRepetition - 1)*driverSettings.cycleLength + (driverSettings.NclockRegions - 1)*driverSettings.clockStep;
%fixed_inactive = num2cell( 0 * ones(1, fixed_value_length ) );
fixed_one = num2cell(-driverSettings.maxVoltage * ones(1, fixed_value_length));
fixed_zero = num2cell(driverSettings.maxVoltage * ones(1, fixed_value_length));
dr_pos_sweep = num2cell([D D1]); % sweep from low to high values
dr_neg_sweep = num2cell([not_D D0]); % sweep from high to low values
 
Ndrivers = length(driverSettings.driverNames);

%initialize valuesDr cell array
if driverSettings.doubleMolDriver
    valuesDr = cell(Ndrivers*2,fixed_value_length*Ncomb(1)+1); %nrows = number of driver times 2 because the doubleDriverMode,ncol = length of the input values + 1 for the input name
else
    valuesDr = cell(Ndrivers,fixed_value_length*Ncomb(1)+1); % not in doubleDriverMode, so just one row per input
end


for ii = 1:Ndrivers    %each ii is a driver
     name = driverSettings.driverNames{ii};
     valuesDr{ii,1} = name; %write dr name in row ii and column 1
            
     if driverSettings.doubleMolDriver
         name_c = [name '_c'];
         valuesDr{ii+Ndrivers,1} = name_c;  %write dr_c name in row ii+Ndrives and column 1, so we obtain Dr1,Dr2,..,DrN,Dr1_c,Dr2_c,..,DrN_c
     end
    
    for j = 1:Ncomb(1)   %every column of driverModes is read and its corresponding array of values is added to the row of valuesDr
        switch driverSettings.driverModes{j,ii}
            case '0'
                [valuesDr{ii,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = fixed_zero{:};
            case '1'
                [valuesDr{ii,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = fixed_one{:};
            case 'sweep'
                [valuesDr{ii,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = dr_pos_sweep{:};
            case 'not_sweep'
                [valuesDr{ii,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = dr_neg_sweep{:};
        end

        if driverSettings.doubleMolDriver 
            switch driverSettings.driverModes{j,ii} 
                % dr_c has opposite value than dr
                case '0'
                    [valuesDr{ii+Ndrivers,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = fixed_one{:};
                case '1'
                    [valuesDr{ii+Ndrivers,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = fixed_zero{:};
                case 'sweep'
                    [valuesDr{ii+Ndrivers,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = dr_neg_sweep{:};
                case 'not_sweep'
                    [valuesDr{ii+Ndrivers,2+(j-1)*fixed_value_length:j*fixed_value_length+1}] = dr_pos_sweep{:};
            end
        end

    end

end