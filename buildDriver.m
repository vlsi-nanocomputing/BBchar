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

D_sweep = repelem(variation, driverSettings.cycleLength); % each element of variation is repeated cycleLength times
D_not_sweep = repelem(not_variation, driverSettings.cycleLength); % each element of not_variation is repeated cycleLength times
% D_one = num2cell(-driverSettings.maxVoltage * ones(1, length(D_sweep)));
% D_zero = num2cell(driverSettings.maxVoltage * ones(1, length(D_sweep)));
D_one = -driverSettings.maxVoltage * ones(1, length(D_sweep));
D_zero = driverSettings.maxVoltage * ones(1, length(D_sweep));

D0 = driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset
D1 = -driverSettings.maxVoltage * ones(1, (driverSettings.NclockRegions - 1) * driverSettings.clockStep); %useful to complete the pattern in the stack phase with the (Nphases - 1) pReset

Ncol = size(driverSettings.driverModes);
Ncomb = Ncol(1);   % the number of rows of driverModes tells the number of driver values' combinations 
fixed_value_length = (driverSettings.NsweepSteps*Ncomb + driverSettings.phasesRepetition - 1)*driverSettings.cycleLength + (driverSettings.NclockRegions - 1)*driverSettings.clockStep;

Ndrivers = length(driverSettings.driverNames);

% creating two temporary structures from which we will copy the values in valuesDr
tmp_valuesDr = cell(Ndrivers,fixed_value_length);
tmp_valuesDr_neg = tmp_valuesDr;

for j = 1:Ndrivers     % reading the j-th driver of driverModes
    D_tot = [];
    for jj = 1:Ncomb     % reading the jj-th value of the same driver
        switch(driverSettings.driverModes{jj,j})
            case '0'
                D_tot = horzcat(D_tot,D_zero);
            case '1'
                D_tot = horzcat(D_tot,D_one);
            case 'sweep'
                D_tot = horzcat(D_tot,D_sweep);
            case 'not_sweep'
                D_tot = horzcat(D_tot,D_not_sweep);
        end
    end

    % adding flap_array to consider the repetition of phases
    if (driverSettings.phasesRepetition > 1)
        flap_array = D_tot(end)*ones( 1, (driverSettings.phasesRepetition - 1)*driverSettings.cycleLength );
        D_tot = horzcat(D_tot,flap_array);
    end
    
    % adding another array to synchronize correctly with buildClock
    if strcmp(driverSettings.driverModes{end,j},'sweep') || strcmp(driverSettings.driverModes{end,j},'1')
        D_tot = horzcat(D_tot,D1);
    elseif strcmp(driverSettings.driverModes{end,j},'not_sweep') || strcmp(driverSettings.driverModes{end,j},'0')
        D_tot = horzcat(D_tot,D0);
    end

    D_tot_neg = -D_tot;
    D_tot = num2cell(D_tot);
    D_tot_neg = num2cell(D_tot_neg);
    [tmp_valuesDr{j,:}] = D_tot{:};
    [tmp_valuesDr_neg{j,:}] = D_tot_neg{:};
end


%initialize valuesDr cell array
if driverSettings.doubleMolDriver
    valuesDr = cell(Ndrivers*2,fixed_value_length+1); %nrows = number of driver times 2 because the doubleDriverMode,ncol = length of the input values + 1 for the input name
else
    valuesDr = cell(Ndrivers,fixed_value_length+1); % not in doubleDriverMode, so just one row per input
end

for ii = 1:Ndrivers
     name = driverSettings.driverNames{ii};
     valuesDr{ii,1} = name; %write dr name in row ii and column 1
            
     if driverSettings.doubleMolDriver
         name_c = [name '_c'];
         valuesDr{ii+Ndrivers,1} = name_c;  %write dr_c name in row ii+Ndrives and column 1, so we obtain Dr1,Dr2,..,DrN,Dr1_c,Dr2_c,..,DrN_c
     end

     [valuesDr{ii,2:end}] = tmp_valuesDr{ii,:};

     if driverSettings.doubleMolDriver 
         [valuesDr{ii+Ndrivers,2:end}] = tmp_valuesDr_neg{ii,:};
     end

end