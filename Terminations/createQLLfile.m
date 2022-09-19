function [terminationFile] =  createQLLfile(termination,nOut,busLayout)
    
    terminationFile = fileread(termination.filepath);
    molLineTemplate = fileread('molLineTemplate.qll');
    
    newID = termination.stack(nOut).StartID;
    newX = termination.stack(nOut).StartX;
    newY = termination.stack(nOut).StartY;
    
    for ii = 1:termination.Length
        strToAdd = molLineTemplate;
        strToAdd = strrep(strToAdd,"$ID$",num2str(newID));
        strToAdd = strrep(strToAdd,"$PHASE$",num2str(termination.stack(nOut).phase));
        strToAdd = strrep(strToAdd,"$X$",num2str(newX(1)));
        strToAdd = strrep(strToAdd,"$Y$",num2str(newY(1)));
        terminationFile = insertBefore(terminationFile,'    </layout>',strToAdd);
        
        if busLayout
            newID = newID + 1;
            strToAdd = molLineTemplate;
            strToAdd = strrep(strToAdd,"$ID$",num2str(newID));
            strToAdd = strrep(strToAdd,"$PHASE$",num2str(termination.stack(nOut).phase));
            strToAdd = strrep(strToAdd,"$X$",num2str(newX(2)));
            strToAdd = strrep(strToAdd,"$Y$",num2str(newY(2)));
            terminationFile = insertBefore(terminationFile,'    </layout>',strToAdd);
        end  
    
        newID = newID + 1;
        if termination.stack(nOut).angle == 0
            newX = newX + 1;
        elseif termination.stack(nOut).angle == 90
            newY = newY + 1;
        elseif termination.stack(nOut).angle == 270
            newY = newY - 1;
        end
        
    end

end