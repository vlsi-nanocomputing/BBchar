%% InOut_eval function


function [Vout] = InOut_eval(sim_path,file,input_values)

    starting_path = fullfile(sim_path,'charResults');   %the path from which the .csv files are taken
    file_name = erase(file,'.qll');   %name of the folder of the circuit that has to be analized 
    dirPath = fullfile(starting_path,file_name);     %path of the folder
    fileid = fopen(fullfile(dirPath,'info.txt'),"r");   %open the file that contains the names of the output files
    first_line = fgets(fileid);   %from the first line of the .txt file I read the names of the output files
    N_outputs = str2double(first_line(20));   %number of outputs --> number of files that are going to be read
    Vout = zeros(1,N_outputs);   %preallocating the temporary Vout array (it will contain as many values as the number of outputs)
    tmp_out_label = cell2mat(split(fgetl(fileid)));   %gets the next line of the .txt file 

    for j = 1:N_outputs
        file_name_tmp = strcat(tmp_out_label(j,:),'.csv');
        out_mat = table2array(readtable(fullfile(dirPath,file_name_tmp)));
        out_mat = round(out_mat,4);   %rounding the values to the 4th decimal digit
        
        %now the drivers of the file are read to see if they correspond to the given inputs
        mat_size = size(out_mat);
        is_out = 0;    %flag that tells whether there is an output value corresponding to the selected inputs
        for m = 1:mat_size(1)
            if isequal(out_mat(m,2:end),input_values) 
                is_out = 1;
                Vout(j) = out_mat(m,1);
            end
        end
        if is_out == 0    %if there is no value corresponding to the selected inputs
            model = fitlm(out_mat(:,2:end),out_mat(:,1));
            Vout(j) = model.Coefficients.Estimate(1);
            for d = 2:length(input_values)+1
                Vout(j) = Vout(j) + model.Coefficients.Estimate(d)*input_values(d-1);
            end
        end
    end

end

    
