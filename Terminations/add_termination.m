function [QCAcircuit, termination] = add_termination(QCAcircuit, settings, pCycle, pResetLength)

    if settings.enableTermination % if the user want to add the termination
        
        % Read the circuit qll file and extract the name and the number of the independent output
        CUTstruct = xmlRead(QCAcircuit.qllFile); 
        [outNames,indexName] = unique( CUTstruct.output.name );
        Noutputs = length(outNames);
        
        if settings.busLayout && Noutputs == length(CUTstruct.output.name)
            error("Dependent output in bus layout MUST have the same name. Please correct the layout!");
        end
        
        if isfield(settings,'customLength') && settings.customLength ~= 0 
            termination.Length = settings.customLength;
        else
            termination.Length = 4; %default termination has 8 molecules (4 cells)
        end
        
        termination.numOutput = Noutputs;
        termination.filepath = insertBefore(QCAcircuit.qllFile,'.qll','_termination');
        copyfile(QCAcircuit.qllFile, termination.filepath);
        
        %add for cycle for each output
        for nOut = 1:Noutputs
            % get output info
            OUT_x = CUTstruct.output.x(indexName(nOut)); % xcoo of the out1
            OUT_y = CUTstruct.output.y(indexName(nOut));
            OUT_angle = CUTstruct.output.angle(indexName(nOut));
        
            if OUT_angle == 0
                test_x = OUT_x - 1;
            elseif OUT_angle == 90
                test_y = OUT_y - 1;
            elseif OUT_angle == 270
                test_y = OUT_y + 1;
            else
                error('Angle not compatible with the actual program. Please correct the .qll and try again');
            end

            %find the molecule near the output and read the phase
            if exist('test_x','var')
                index = find([CUTstruct.molecules(:).x] == test_x);
                nearMolPhase = CUTstruct.molecules(index(1)).phase;
            elseif exist('test_y','var')
                index = find([CUTstruct.molecules(:).y] == test_y);
                nearMolPhase = CUTstruct.molecules(index(1)).phase; 
            else
                error('No molecule near the output: check and correct the layout')
            end
            Nphases = max([CUTstruct.molecules(:).phase]) + 1;
            termination.stack(nOut).phase = mod(nearMolPhase+1,Nphases);
    
            % Compute every id used in the original qll to extract the next one to use
            mol_id_MAX = max(str2double([CUTstruct.molecules(:).id]));
            out_id_MAX = max(str2double([CUTstruct.output(:).id]));
            drv_id_MAX = max(str2double([CUTstruct.driver(:).id]));
            id_MAX = max([mol_id_MAX out_id_MAX drv_id_MAX]);
            termination.stack(nOut).StartID = id_MAX +1;
        
            if settings.busLayout
                termination.stack(nOut).StartX = [CUTstruct.output.x(indexName(nOut)) CUTstruct.output.x(indexName(nOut) + 1)];
                termination.stack(nOut).StartY = [CUTstruct.output.y(indexName(nOut)) CUTstruct.output.y(indexName(nOut) + 1)];
            else
                termination.stack(nOut).StartX = CUTstruct.output.x(indexName(nOut));
                termination.stack(nOut).StartY = CUTstruct.output.y(indexName(nOut));
            end
            termination.stack(nOut).angle = OUT_angle;

            terminationFileContent = createQLLfile(termination,nOut,settings.busLayout);
            fileID = fopen(termination.filepath,'w');  
            fprintf(fileID,terminationFileContent);
            fclose(fileID);

        end

        % Update Values_Dr and stack_phase

        %Evaluate the last driver value to copy it n-times at the end
        driver_last_value = QCAcircuit.Values_Dr(:,end); 
        %Create the matrix of repeated values to attach at the end of Values_Dr
        flap_matrix = repmat(driver_last_value,1,length(pCycle));
        %Attach flap matrix
        QCAcircuit.Values_Dr = [QCAcircuit.Values_Dr flap_matrix];  
        
        %Insert a pCycle in stack_phase in the correct position for each
        %row, considering the presence of the pReset filler
        newPhaseMatrix = zeros(size(QCAcircuit.stack_phase,1),size(QCAcircuit.stack_phase,2) + length(pCycle));
        for ii = 1:size(QCAcircuit.stack_phase,1)
            pos = [1:length(pCycle)] + pResetLength*(ii-1);
            idx = ones(1,length(newPhaseMatrix));
            idx(pos) = 0;
            newPhaseMatrix(ii,pos) = pCycle;
            newPhaseMatrix(ii,logical(idx)) = QCAcircuit.stack_phase(ii,:);
        end
        QCAcircuit.stack_phase = newPhaseMatrix;

    else %termination not enabled
        termination.num = 0;
    end
    
end
    
    
    