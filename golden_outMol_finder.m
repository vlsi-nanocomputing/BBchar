%% golden_outMol_finder function

% This function, starting from the layout of the circuit, returns the names of the outputs and of the clock signals
% (respectively in the format 'Vout_00xxa' and 'CK_00xxa') that will be retrieved in the file 'Additional_Information.txt'
% in order to extract the .csv files

function [output_data] = golden_outMol_finder(simulation_path, bus_flag, OUT_angle)

    % Tables loading
    tableNMol = load(fullfile(simulation_path,'simulation_output.mat')); %Load the table with every simulated value for the layout
    
    %output coordinates from stack_output
    N_outputs = tableNMol.stack_output.num;
    for j = 1:N_outputs
        tmp_string = tableNMol.stack_output.stack(j).position;     %extracting the strings with output coordinates ([x y z])
        out_coord(j,:) = str2num(tmp_string);    %matrix that contains the coordinates of the outputs
        original_coord(j,:) = out_coord(j,:);    %coordinates of the inputs as read from the initial file
    end

    
    %Evaluating the coordinates of the molecules right before the terminations
      
    if bus_flag == 0    %not-bus structure
        for k = 1:length(OUT_angle)
            switch OUT_angle(k)
                case 0
                    out_coord(k,3) = out_coord(k,3) - 3;     %HORIZONTAL OUTPUT PROPAGATION --> 3 molecules to the left
                case 90 
                    out_coord(k,2) = out_coord(k,2) - 2;     %VERTICAL DOWNWARD PROPAGATION --> 2 molecules up
                case 270
                    out_coord(k,2) = out_coord(k,2) + 2;     %VERTICAL UPWARD PROPAGATION   --> 2 molecules down
            end
        end
    
    elseif bus_flag == 1     %bus structure
        for k = 1:length(OUT_angle)
            switch OUT_angle(k)
                case 0
                    out_coord(k,3) = out_coord(k,3) - 3;     %HORIZONTAL OUTPUT PROPAGATION --> 3 molecules to the left
                    out_coord(k+1,3) = out_coord(k+1,3) - 3;     
                case 90
                    out_coord(k,2) = out_coord(k,2) - 2;     %VERTICAL DOWNWARD PROPAGATION --> 2 molecules up
                    out_coord(k+1,2) = out_coord(k+1,2) - 2;     
                case 270
                    out_coord(k,2) = out_coord(k,2) + 2;     %VERTICAL UPWARD PROPAGATION   --> 2 molecules down
                    out_coord(k+1,2) = out_coord(k+1,2) + 2;     
            end
        end
    end
    
    % at this point, we know the actual coordinates of the output(s). The next step
    % consists of associating these coordinates to their identifier '000xxa'/'000xxb', in
    % order to be able to retrieve the output(s) in the table, in which they have the form
    % 'Vout_000xxa'
    
    N_mols = tableNMol.stack_mol.num;  
    for s = 1:N_mols
        pos_mol(s,:) = str2num(tableNMol.stack_mol.stack(s).position);   %saving all the coordinates of the molecules
    end
    
    
    for m = 1:N_outputs
        for n = 1:N_mols
            tmp_pos_label = tableNMol.stack_mol.stack(n).identifier_qll;  
            if pos_mol(n,:) == out_coord(m,:)   
               output_labels(m,:) = strcat('Vout_',tmp_pos_label);           
               clock_labels(m,:) = strcat('CK_',tmp_pos_label);              
            elseif pos_mol(n,:) == original_coord(m,:)
               original_clock_labels(m,:) = strcat('CK_',tmp_pos_label);  
            end
        end
    end

    output_data.N_outputs = N_outputs;           %number of outputs
    output_data.pos_mol = pos_mol;               %array with all molecules' positions
    output_data.output_labels = output_labels;   %'Vout_00xx' (termination)
    output_data.clock_labels = clock_labels;     %'CK_00xx' (termination)
    output_data.original_clock_labels = original_clock_labels; %'CK_00xx' (original)
    

end
