%% InOut_eval function

function [Vout] = InOut_eval(LibPath,device,input)

    infoFile = fileread(fullfile(LibPath,device,'info.txt'));   %open the file that contains the names of the output files
    tmp = regexp(infoFile,'Number of outputs\s([0-9]+)\n','tokens');
    num_out = str2double(cell2mat(tmp{1}));
    
    LUTtable = readtable(fullfile(LibPath,device,'table.csv'),'VariableNamesLine',1); 
    availableRows = LUTtable.Properties.VariableNames;
    if isempty(regexp(availableRows{1,end},'Vou_[0-9]*[A|B]_[a-z]?[H|L]', 'once'))
        busFlag = 0;
    else 
        busFlag = 1;
    end
    LUT = table2array(LUTtable);
    num_in = size(LUT,2) - num_out;
    LUT_in = LUT(:,1:num_in);

    if num_in ~= size(input,1)*size(input,2)
        error("The size of the provided input is not consistent with the device.")
    end
    
    in_total = input';
    in_total = in_total(:)';
    dist = vecnorm(LUT_in - in_total, 2, 2);  % calculate the norm of each row of LUT-input
    [~, match] = min(dist); %the nearest vector has the minimun norm
    Vout = reshape(LUT(match,num_in+1:end),2,num_out/2)';
    
end

    
