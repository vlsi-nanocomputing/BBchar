%% InOut_eval function

function [Vout] = InOut_eval(sim_path,file,input)

    starting_path = fullfile(sim_path,'charResults');   %the path from which the .csv files are taken
    file_name = erase(file,'.qll');   %name of the folder of the circuit that has to be analized   
    dirPath = fullfile(starting_path,file_name);     %path of the folder
    fileid = fopen(fullfile(dirPath,'info.txt'),"r");   %open the file that contains the names of the output files
    first_line = fgets(fileid);   %from the first line of the .txt file I read the names of the output files
    N_outputs = str2double(first_line(20));   %number of outputs --> number of files that are going to be read
    outputs = split(fgetl(fileid));   %gets the names of the outputs in a string column array

    for k = 1:N_outputs
        file_name_tmp = strcat(outputs{k,:},'.csv');
        out_mat = table2array(readtable(fullfile(dirPath,file_name_tmp)));
        
        %the drivers of the file are read to see if they correspond to the given inputs
        mat_size = size(out_mat);
        Ncol = mat_size(2);
        diff_rows = mat_size(1);
        diff_cols = mat_size(2) - 1;
        diff_mat = zeros(diff_rows,diff_cols);
        column_min = zeros(1,diff_cols);
  
        for c = 2:Ncol
            diff_mat(:,c-1) = abs(out_mat(:,c)-input(c-1));   % finding the value in the c-th column that is nearest to the input one
            column_min(c-1) = min(diff_mat(:,c-1));   %minimum value of each column
        end

        %arrow that contains the number of minima in a row (its dimension
        %is the number of rows)
        cnt_min = zeros(1,diff_rows);   

        for i = 1:diff_rows
            for j = 1:diff_cols
                if diff_mat(i,j) == column_min(j)
                    cnt_min(i) = cnt_min(i) + 1;
                end
            end
        end

        [~,out_pos] = max(cnt_min);

        % loading the output structure with the names of the outputs and the corresponding values
        Vout.(outputs{k,:}) = out_mat(out_pos,1);  
    end
end

    
