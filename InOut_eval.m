%% InOut_eval function


function [Vout] = InOut_eval(sim_path,file,input)

    starting_path = fullfile(sim_path,'charResults');   %the path from which the .csv files are taken
    file_name = erase(file,'.qll');   %name of the folder of the circuit that has to be analized   
    dirPath = fullfile(starting_path,file_name);     %path of the folder
    fileid = fopen(fullfile(dirPath,'info.txt'),"r");   %open the file that contains the names of the output files
    first_line = fgets(fileid);   %from the first line of the .txt file I read the names of the output files
    N_outputs = str2double(first_line(20));   %number of outputs --> number of files that are going to be read
    outputs = split(fgetl(fileid));   %gets the names of the outputs in a string column array

    for j = 1:N_outputs
        file_name_tmp = strcat(outputs{j,:},'.csv');
        out_mat = table2array(readtable(fullfile(dirPath,file_name_tmp)));
        
        %the drivers of the file are read to see if they correspond to the given inputs
        mat_size = size(out_mat);
        Ncol = mat_size(2);
        vector = zeros(1,Ncol-1);
        for c = 2:Ncol
            [~,pos] = min(abs(out_mat(:,c)-input(c-1)));   % finding the value in the c-th column that is nearest to the input one
            vector(c-1) = out_mat(pos,1);  %contains all the output that correspond to the inputs (the nearest ones)
        end
        nearest = sum(vector)/length(vector);    %evaluating an average value of the output values in vector
        [~,pos_near] = min(abs(out_mat(:,1)-nearest));

        % loading the output structure with the names of the outputs and the corresponding values
        Vout.(outputs{j,:}) = out_mat(pos_near,1);  
    end
end


    
