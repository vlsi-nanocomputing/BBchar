%% VIN/VOUT - CHARACTERISTIC

function characterization(charSettings,terminationSettings,terminationCircuit,driverPara,drivers)
        
% Paths definition
if ~isfolder(charSettings.LibPath)
    mkdir(charSettings.LibPath);     % creating main Library directory if it doesn't exist already
end
currentDeviceLibPath = fullfile(charSettings.LibPath,charSettings.LibDeviceName);    % path of the directory related to the specific circuit
if ~isfolder(currentDeviceLibPath)
    mkdir(currentDeviceLibPath);     
end
outFolderPath = fullfile(charSettings.out_path,'SCERPA_OUTPUT_FILES');

% Read simulation data
table_AI = readtable(fullfile(outFolderPath,'Additional_Information.txt'),'VariableNamesLine',1); %Create a table from the file to read voltages
table_AI.Properties.VariableNames{1} = 'Time'; %rename time column
availableRows = table_AI.Properties.VariableNames;
table_AI_array = table2array(table_AI);

bus_flag = terminationSettings.busLayout;   %flag that tells whether it is a bus layout or not


%% Extract output values from the table
% Evaluating the position as expressed in the qll file of the molecules right before the terminations and associate thw new names for the table
for oo = 1:terminationCircuit.numOutput
    switch terminationCircuit.stack(oo).angle
        case 0
            if bus_flag
                out_pos_qll((2*oo-1):(2*oo),:) = [zeros(2,1) terminationCircuit.stack(oo).StartY'  (terminationCircuit.stack(oo).StartX-1)'];
                new_outNames{4*oo-3} = sprintf('Vou_%dA_H',oo);
                new_outNames{4*oo-2} = sprintf('Vou_%dB_H',oo);
                new_outNames{4*oo-1} = sprintf('Vou_%dA_L',oo);
                new_outNames{4*oo} = sprintf('Vou_%dB_L',oo);
            else
                out_pos_qll(oo,:) = [0 terminationCircuit.stack(oo).StartY'  (terminationCircuit.stack(oo).StartX-1)'];
                new_outNames{2*oo-1} = sprintf('Vou_%dA',oo);
                new_outNames{2*oo} = sprintf('Vou_%dB',oo);
            end
        case 90
            if bus_flag
                out_pos_qll((2*oo-1):(2*oo),:) = [zeros(2,1) (terminationCircuit.stack(oo).StartY-1)'  terminationCircuit.stack(oo).StartX'];
                new_outNames{4*oo-3} = sprintf('Vou_%dA_dH',oo);
                new_outNames{4*oo-2} = sprintf('Vou_%dB_dH',oo);
                new_outNames{4*oo-1} = sprintf('Vou_%dA_dL',oo);
                new_outNames{4*oo} = sprintf('Vou_%dB_dL',oo);
            else
                out_pos_qll(oo,:) = [0 (terminationCircuit.stack(oo).StartY-1)'  terminationCircuit.stack(oo).StartX'];
                new_outNames{2*oo-1} = sprintf('Vou_%dA_d',oo);
                new_outNames{2*oo} = sprintf('Vou_%dB_d',oo);
            end
        case 270
            if bus_flag
                out_pos_qll((2*oo-1):(2*oo),:) = [zeros(2,1) (terminationCircuit.stack(oo).StartY+1)'  terminationCircuit.stack(oo).StartX'];
                new_outNames{4*oo-3} = sprintf('Vou_%dA_uH',oo);
                new_outNames{4*oo-2} = sprintf('Vou_%dB_uH',oo);
                new_outNames{4*oo-1} = sprintf('Vou_%dA_uL',oo);
                new_outNames{4*oo} = sprintf('Vou_%dB_uL',oo);
            else
                out_pos_qll(oo,:) = [0 (terminationCircuit.stack(oo).StartY+1)'  terminationCircuit.stack(oo).StartX'];
                new_outNames{2*oo-1} = sprintf('Vou_%dA_u',oo);
                new_outNames{2*oo} = sprintf('Vou_%dB_u',oo);
            end
    end
end

%read the qll to extract the qll_identifier and the phase 
qllFile_term = fileread(fullfile(charSettings.out_path,strcat(charSettings.LibDeviceName,'_termination.qll')));
abq = '([^"]+)';    % anything but quotation mark
for oo = 1:size(out_pos_qll,1)
    xpr = ['<item comp="',abq,'" id="',abq,'"( angle="',abq,'")? x="',num2str(out_pos_qll(oo,3)),'" y="',num2str(out_pos_qll(oo,2)),'" layer="0">(\s*<property name="',abq,'" value="',abq,'"/>)*'];
    tmp = regexp(qllFile_term, xpr, 'tokens');
    outID{2*oo-1} = ['Vout_' sprintf('%.4da',str2double(tmp{1,1}{1,2}))];
    outID{2*oo} = ['Vout_' sprintf('%.4db',str2double(tmp{1,1}{1,2}))];
    % get the phase of each output molecules
    phasecell = regexp(tmp{1,1}{1,4}, ['\s*<property name="phase" value="',abq,'"/>'], 'tokens');
    outPhase(2*oo-1) = str2double(phasecell{1,1})+1;
    outPhase(2*oo) = str2double(phasecell{1,1})+1;
end
% extract the column indexes of the table where output voltages are stores
index = contains(availableRows,outID);
out_cols = find(index==1);

%% Get the driver values list from the driver
[driverValues,index] = unique(cell2mat(drivers(:,2:end)).','rows','stable'); % values are the first occurence
driverValues = driverValues.';
Ndrivers = length(driverPara.driverNames);
for dd = 1:Ndrivers
    new_driverNames{dd} = sprintf('Vin_%dA',dd);
    new_driverNames{dd+Ndrivers} = sprintf('Vin_%dB',dd);
end

%% Extract the time instants (table rows) corresponding with the output in the hold phase for the selected input combination
%the first time depend on the output phase and the phase repetition in the circuit, the others are separated by a cycle lenght
time_rows = index + outPhase.*driverPara.clockStep + (driverPara.cycleLength * (driverPara.phasesRepetition -1)); 

%% Generate the lookup table and save it to the library
table_header = [new_driverNames new_outNames];
table_values = zeros(size(driverValues,2),size(driverValues,1)+length(out_cols));
for comb = 1:size(driverValues,2)
    table_values(comb,:) = [driverValues(:,comb)' diag((table_AI_array(time_rows(comb,:),out_cols)),0)'];
end
T = array2table(table_values,'VariableNames',table_header);   %creating the table containing output and drivers
file_name = strcat(charSettings.LibDeviceName,'.csv');
path = fullfile(currentDeviceLibPath,file_name);
writetable(T,path);   %creation of the .csv file

%% Generate the additional information file and save it to the library
%saving the min and max coordinates in y-axis and z-axis (to evaluate the number of cells)
qllFile = fullfile(charSettings.out_path,strcat(charSettings.LibDeviceName,'.qll'));
circuit = xmlRead(qllFile);

ymin = min([circuit.molecules.y]);
ymax = max([circuit.molecules.y]);
zmin = min([circuit.molecules.x]);
zmax = max([circuit.molecules.x]);
y_cell_num = (ymax - ymin + 1);
z_cell_num = (zmax - zmin + 1);
area_cells = y_cell_num*z_cell_num;

latency = driverPara.phasesRepetition*driverPara.NclockRegions;   %latency of the circuit

% writing the .txt file with the additional informations
fileid = fopen(fullfile(currentDeviceLibPath,'info.txt'),'w');
fprintf(fileid,'Number of outputs\t%d\n',length(outID));
for w = 1:length(outID)
    fprintf(fileid,'%s\t',new_outNames{w});
end
fprintf(fileid,'\nLatency\t%d',latency);
fprintf(fileid,'\nNumber of clock phases\t%d',driverPara.NclockRegions);
fprintf(fileid,'\nMaximum driver voltage\t%.2f V',driverPara.maxVoltage);
fprintf(fileid,'\nTotal area\t%dx%d=%d',y_cell_num,z_cell_num,area_cells);
fclose(fileid);

end