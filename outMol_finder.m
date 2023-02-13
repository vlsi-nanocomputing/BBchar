%% outMol_finder function

% This function, starting from the layout of the circuit, returns the names of the outputs and of the clock signals
% (respectively in the format 'Vout_00xxa' and 'CK_00xxa') that will be retrieved in the file 'Additional_Information.txt'
% in order to extract the .csv files

function [output_data] = outMol_finder(simulation_path, bus_flag, OUT_angle)

    % Tables loading
    tableNMol = load(fullfile(simulation_path,'simulation_output.mat')); %Load the table with every simulated value for the layout
    
    %output coordinates from stack_output
    N_outputs = tableNMol.stack_output.num;
    termination_coord = zeros(N_outputs,3);     %preallocating termination_coord
    for j = 1:N_outputs     
        termination_coord(j,:) = str2num(tableNMol.stack_output.stack(j).position);    %coordinates of the inputs ([x y z]) as read from the initial file
    end

    %%% Evaluating the coordinates of the molecules right before the terminations %%%
    
    if bus_flag == 0    %not-bus structure
        out_coord = termination_coord;
        for k = 1:length(OUT_angle)
            switch OUT_angle(k)
                case 0
                    out_coord(k,3) = out_coord(k,3) - 2;     %HORIZONTAL OUTPUT PROPAGATION --> 3 molecules to the left
                case 90 
                    out_coord(k,2) = out_coord(k,2) - 2;     %VERTICAL DOWNWARD PROPAGATION --> 2 molecules up
                case 270
                    out_coord(k,2) = out_coord(k,2) + 2;     %VERTICAL UPWARD PROPAGATION   --> 2 molecules down
            end
        end
    
    elseif bus_flag == 1     %bus structure
        if length(OUT_angle) == 1
            termination_coord = [repmat(termination_coord(1,:),2,1);repmat(termination_coord(2,:),2,1)];
            switch OUT_angle(1)
                case 0        %HORIZONTAL OUTPUT PROPAGATION --> 2 molecules to the left
                    termination_coord(1,3) = termination_coord(3,3) - 1;
                    termination_coord(3,3) = termination_coord(4,3) - 1;
                    out_coord = termination_coord;
                    for j = 1:4
                        out_coord(j,3) = out_coord(j,3) - 2;
                    end
                case 90       %VERTICAL DOWNWARD PROPAGATION --> 2 molecules up   
                    termination_coord(1,3) = termination_coord(1,3) - 1;
                    termination_coord(3,3) = termination_coord(3,3) - 1;
                    out_coord = termination_coord;
                    for j = 1:4
                        out_coord(j,2) = out_coord(j,2) - 1;
                    end
                case 270      %VERTICAL UPWARD PROPAGATION   --> 2 molecules down
                    termination_coord(1,3) = termination_coord(1,3) - 1;
                    termination_coord(3,3) = termination_coord(3,3) - 1;
                    out_coord = termination_coord;
                    for j = 1:4
                        out_coord(j,2) = out_coord(j,2) + 1;
                    end  
            end
            
        elseif length(OUT_angle) == 2
            termination_coord = [repmat(termination_coord(1,:),2,1);repmat(termination_coord(2,:),2,1); ...
                              repmat(termination_coord(3,:),2,1);repmat(termination_coord(4,:),2,1)];
            for t = 1:2:length(termination_coord)
                termination_coord(t,3) = termination_coord(t,3) - 1;
            end
            out_coord = termination_coord;
            len = length(termination_coord)/2;

            if isequal(OUT_angle,[0,90])
                for k = 1:len
                    out_coord(k,2) = out_coord(k,2) - 1;
                    out_coord(k+len,3) = out_coord(k+len,3) - 2;
                end
            elseif isequal(OUT_angle,[0,270])
                for k = 1:len
                    out_coord(k,3) = out_coord(k,3) - 2;
                    out_coord(k+len,2) = out_coord(k+len,2) + 1;
                end
            elseif isequal(OUT_angle,[270,90])
                for k = 1:len
                    out_coord(k,2) = out_coord(k,2) - 1;
                    out_coord(k+len,2) = out_coord(k+len,2) + 1;
                end
            else
                warning('Unknown configuration');
            end
        end
    end
    
    % at this point, we know the actual coordinates of the output(s), saved as out_coord. The next step
    % consists of associating these coordinates to their identifier '000xxa'/'000xxb', in
    % order to be able to retrieve the output(s) in the table, in which they have the form
    % 'Vout_000xxa'
    
    N_mols = tableNMol.stack_mol.num;
    pos_mol = zeros(N_mols,3);
    for s = 1:N_mols
        pos_mol(s,:) = str2num(tableNMol.stack_mol.stack(s).position);   %saving all the coordinates of the molecules
    end
    
    output_labels = cell(N_outputs*2,1);
    clock_labels = cell(N_outputs*2,1);
    termination_clock_labels = cell(N_outputs*2,1);
    for m = 1:N_outputs*2
        for n = 1:N_mols
            if pos_mol(n,:) == out_coord(m,:)   
               output_labels{m,:} = strcat('Vout_',tableNMol.stack_mol.stack(n).identifier_qll);           
               clock_labels{m,:} = strcat('CK_',tableNMol.stack_mol.stack(n).identifier_qll);               
            end
            if pos_mol(n,:) == termination_coord(m,:)
                termination_clock_labels{m,:} = strcat('CK_',tableNMol.stack_mol.stack(n).identifier_qll);
            end
        end
    end
    

    output_data.N_outputs = N_outputs;           %number of outputs
    output_data.pos_mol = pos_mol;               %array with all molecules' positions
    output_data.out_coord = out_coord;           %actual outputs' coordinates
    output_data.output_labels = cell2mat(output_labels);   %'Vout_00xx' 
    output_data.clock_labels = cell2mat(clock_labels);     %'CK_00xx'
    output_data.termination_clock_labels = cell2mat(termination_clock_labels); %'CK_00xx' 
    

end
