%% VIN/VOUT - CHARACTERISTIC

function characterization(charSettings,file,terminationSettings,terminationCircuit,driverPara,BBcharPath)
        
    % Paths definition
    simulation_path = charSettings.out_path;
    if ~isfolder(fullfile(BBcharPath,'charResults'))
        mkdir(fullfile(BBcharPath,charResults));     % creating main characterization directory (if it doesn't already exist)
    end
    charPath = fullfile(BBcharPath,'charResults');  
    dir_name = erase(file,'.qll');   %defining the name of the directory that will contain characterization results of the specific circuit
    if ~isfolder(fullfile(charPath,dir_name))
        mkdir(fullfile(charPath,dir_name));     
    end
    dirPath = fullfile(charPath,dir_name);    % path of the directory related to the specific circuit
    
    table = readtable(fullfile(simulation_path,'Additional_Information.txt')); %Create a table from the file to read voltages
    tableNMol = load(fullfile(simulation_path,'simulation_output.mat')); %Load the table with every simulated value for the layout
    
    %Importing variables from launchScript
    bus_flag = terminationSettings.busLayout;   %flag that tells whether it is a bus layout or not
    term_angle = zeros(1,length(terminationCircuit.stack));    %preallocating 
    for z = 1:length(terminationCircuit.stack)
        term_angle(z) = terminationCircuit.stack(z).angle;     %I save the angle(s) of the circuit in an array
    end
    
    latency = driverPara.phasesRepetition;   %latency of the circuit
    N_clk_regions = driverPara.NclockRegions;   %number of clock regions (phases) of the layout
    max_Voltage = driverPara.maxVoltage;    %maximum voltage (abs value) the driver will assume in Volts

    A = outMol_finder(simulation_path, bus_flag, term_angle);

    % saving the names of the drivers in a string array
    N_drivers = tableNMol.stack_driver.num;
    for dd = 1:N_drivers
        driver_labels_qll(dd,:) = strcat('driver_',tableNMol.stack_driver.stack(dd).identifier_qll);
        driver_labels{dd,:} = tableNMol.stack_driver.stack(dd).identifier;
    end

    for a = 2:length(table.Properties.VariableDescriptions)        % scanning the names of the original table's columns
        heading = cell2mat(table.Properties.VariableDescriptions(1,a));
        for b = 1:A.N_outputs*2
            if strcmp(heading,A.clock_labels(b,:)) == 1       %if the title corresponds to one of the clock names ...
                clock_mat(:,b) = table{:,a};                   %the entire column of the table is copied in clock_mat
            elseif strcmp(heading,A.output_labels(b,:)) == 1   %same thing for the output names
                output_mat(:,b) = table{:,a};
            elseif strcmp(heading,A.original_clock_labels(b,:)) == 1
                original_clock_mat(:,b) = table{:,a};
            end
        end
        for c = 1:N_drivers
            if strcmp(heading,driver_labels_qll(c,:)) == 1
                driver_mat(:,c) = table{:,a};
            end
        end
    end

    %Now we collected the indices of the columns that we are interested in,
    %and copied the correspondent columns into new structures.
    %The next step is to check the time steps in which the selected clocks
    %are in HOLD, in order to save the equivalent outputs and drivers

    % removing complementary drivers (i.e. Dr1_c, Dr2_c, Dr3_c)
    for j = 1:N_drivers
        tmp_str = char(driver_labels(j));
        if tmp_str(end) ~= 'c'
            dr_table{j} = driver_labels(j,:);     %table containing the (true) names of the drivers
        else
            comp_array{j} = j;    %this array tells which columns of the driver_mat to eliminate 
        end
    end
    dr_table = dr_table(~cellfun('isempty',dr_table));         %removing empty values 
    comp_array = comp_array(~cellfun('isempty',comp_array));   %removing empty values   
    dr_array = string(dr_table);
    comp_array = cell2mat(comp_array);
    for jj = length(comp_array):-1:1
        driver_mat(:,comp_array(jj)) = [];   %removing all the columns that contain the data related to complementary drivers
    end

    saved_outputs = NaN(length(output_mat),1);             %preallocating output array
    saved_drivers = NaN(length(driver_mat),N_drivers/2);   %preallocating driver matrix

    %The aim of the following for cycle is to rename the drivers in the %dr_array.
    %This is necessary since there are two columns for 'Dr1', two for 'Dr2' and so on.
    %Each couple of identical drivers is named as, for instance, 'Dr1_a' and 'Dr1_b' in order to distinguish the two.

    for y = 1:2:length(dr_array)-1
       dr_array(y) = strcat(dr_array(y),'_a');
       dr_array(y+1) = strcat(dr_array(y+1),'_b');
    end

    ABCD_names = rename_outputs(A.out_coord).final_string;   %substituting the original labels with Vout_A, ecc.

    delay = driverPara.phasesRepetition * driverPara.cycleLength;   %clock steps that separate the input from the corresponding output

    %%%%%%%%    generating a .csv file for each output    %%%%%%%%
    for d = 1:A.N_outputs*2
        headers_array = [ABCD_names(d,:) dr_array];   %array of strings containing the headers of the d-th .csv file
        for e = delay+1:length(clock_mat)
            if clock_mat(e,d) == 2 && original_clock_mat(e,d) == 2      %check if output and termination are in HOLD state
                saved_outputs(e,1) = output_mat(e,d);  %outputs that are going to be stored in the .csv file
                saved_drivers(e,:) = driver_mat(e-delay,:);  %drivers that are going to be stored in the .csv file
            end
        end
        final_mat = rmmissing(cat(2,saved_outputs,saved_drivers));  %concatenating outputs and drivers in a matrix and then removing NaN values from it
        T = array2table(final_mat,'VariableNames',headers_array);   %creating the table containing output and drivers
        T = unique(T);   %eliminating equal rows
        file_name = strcat(ABCD_names(d,:),'.csv');
        path = fullfile(dirPath,file_name);
        writetable(T,path);   %creation of the .csv file
    end
    
    %%%%%%%%%    EVALUATING THE AREA OF THE CIRCUIT    %%%%%%%%

    %saving the min and max coordinates in y-axis and z-axis (to evaluate the number of cells)
    ymin = min(A.pos_mol(:,2));
    ymax = max(A.pos_mol(:,2));
    zmin = min(A.pos_mol(:,3));
    zmax = max(A.pos_mol(:,3));
    N_cells = (ymax - ymin)*(zmax - zmin);

    % distance between Dot1 and Dot2 inside a single molecule (on y-axis)
    deltay = tableNMol.stack_mol.stack(1).charge(2).y - tableNMol.stack_mol.stack(1).charge(1).y;

    % distance between the Dot1 of two adjacent molecules (on z-axis)
    found = 0;
    p = 1;
    while found == 0
        first_z = str2num(tableNMol.stack_mol.stack(p).position);   
        second_z = str2num(tableNMol.stack_mol.stack(p+1).position);    
        if abs(first_z(3) - second_z(3)) == 1
            found = 1;
            deltaz = tableNMol.stack_mol.stack(p).charge(1).z - tableNMol.stack_mol.stack(p+1).charge(1).z;
        end
    end
    
    % total area will be the product of the area between two adjacent molecules and the number of cells
    total_area = (deltaz*deltay)*N_cells;

    %%%%%%%%%%    WRITING THE .txt FILE WITH ADDITIONAL INFORMATION    %%%%%%%%%%
    fileid = fopen(fullfile(dirPath,'info.txt'),"w");
    fprintf(fileid,'Number of outputs: %d\n',A.N_outputs*2);
    for w = 1:A.N_outputs*2
        fprintf(fileid,'%s ',ABCD_names(w,:));
    end
    fprintf(fileid,'\nLatency of the circuit is %d',latency);
    fprintf(fileid,'\nNumber of clock phases is %d',N_clk_regions);
    fprintf(fileid,'\nMaximum driver voltage is %.2f V',max_Voltage);
    fprintf(fileid,'\nTotal area is %.2f nm^2',total_area);
    fclose(fileid);

end