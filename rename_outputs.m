%% function to assign the names Vout_A, Vout_B, Vout_C, Vout_D

function [ordered_data] = rename_outputs(out_coord, angle)

    min_z = min(out_coord(:,3));
    max_z = max(out_coord(:,3));
    min_y = min(out_coord(:,2));
    max_y = max(out_coord(:,2));

    if length(angle) == 1
        out_labels = cell(4,1);
        if angle(1) == 0
            for j = 1:length(out_coord)
                if out_coord(j,3) == max_z
                    if out_coord(j,2) == min_y
                        out_labels{j,:} = 'Vout_A';
                    elseif out_coord(j,2) == max_y
                        out_labels{j,:} = 'Vout_C';
                    end
                elseif out_coord(j,3) == min_z
                    if out_coord(j,2) == min_y
                        out_labels{j,:} = 'Vout_B';
                    elseif out_coord(j,2) == max_y
                        out_labels{j,:} = 'Vout_D';
                    end
                end
            end
        elseif angle(1) == 90 
            for j = 1:length(out_coord)
                switch out_coord(j,3)
                    case max_z
                        out_labels{j,:} = 'Vout_A_d';
                    case max_z - 1
                        out_labels{j,:} = 'Vout_B_d';
                    case min_z + 1
                        out_labels{j,:} = 'Vout_C_d';
                    case min_z
                        out_labels{j,:} = 'Vout_D_d';
                end
            end
        elseif angle(1) == 270
            for j = 1:length(out_coord)
                switch out_coord(j,3)
                    case max_z
                        out_labels{j,:} = 'Vout_A_u';
                    case max_z - 1
                        out_labels{j,:} = 'Vout_B_u';
                    case min_z + 1
                        out_labels{j,:} = 'Vout_C_u';
                    case min_z
                        out_labels{j,:} = 'Vout_D_u';
                end
            end
        end


    elseif length(angle) == 2
        out_labels = cell(8,1);

        if isequal(angle,[270,90])
            for j = 1:length(out_coord)
                if out_coord(j,2) == min_y      % upward branch of the T ramification
                    switch out_coord(j,3)
                        case max_z
                            out_labels{j,:} = 'Vout_A_u';
                        case min_z
                            out_labels{j,:} = 'Vout_D_u';
                        case min_z + 1
                            out_labels{j,:} = 'Vout_C_u';
                        case max_z - 1
                            out_labels{j,:} = 'Vout_B_u';
                    end
                elseif out_coord(j,2) == max_y    % downward branch of the T ramification
                    switch out_coord(j,3)
                        case max_z
                            out_labels{j,:} = 'Vout_A_d';
                        case min_z
                            out_labels{j,:} = 'Vout_D_d';
                        case min_z + 1
                            out_labels{j,:} = 'Vout_C_d';
                        case max_z - 1
                            out_labels{j,:} = 'Vout_B_d';
                    end
                end
            end
        elseif isequal(angle,[0,90])
            for j = 1:length(out_coord)
                if out_coord(j,2) == max_y    % downward branch of the T ramification
                    switch out_coord(j,3)
                        case min_z
                            out_labels{j,:} = 'Vout_D_d';
                        case min_z + 1
                            out_labels{j,:} = 'Vout_C_d';
                        case min_z + 2
                            out_labels{j,:} = 'Vout_B_d';
                        case min_z + 3
                            out_labels{j,:} = 'Vout_A_d';
                    end
                else 
                    if out_coord(j,2) == min_y
                        if out_coord(j,3) == max_z
                            out_labels{j,:} = 'Vout_A';
                        else 
                            out_labels{j,:} = 'Vout_B';
                        end
                    else
                        if out_coord(j,3) == max_z
                            out_labels{j,:} = 'Vout_C';
                        else
                            out_labels{j,:} = 'Vout_D';
                        end
                    end
                end
            end
        elseif isequal(angle,[0,270])
            for j = 1:length(out_coord)
                if out_coord(j,2) == min_y    % upward branch of the T ramification
                    switch out_coord(j,3)
                        case min_z
                            out_labels{j,:} = 'Vout_D_u';
                        case min_z + 1
                            out_labels{j,:} = 'Vout_C_u';
                        case min_z + 2
                            out_labels{j,:} = 'Vout_B_u';
                        case min_z + 3
                            out_labels{j,:} = 'Vout_A_u';
                    end
                else
                    if out_coord(j,2) == max_y
                        if out_coord(j,3) == max_z
                            out_labels{j,:} = 'Vout_C';
                        else 
                            out_labels{j,:} = 'Vout_D';
                        end
                    else
                        if out_coord(j,3) == max_z
                            out_labels{j,:} = 'Vout_A';
                        else
                            out_labels{j,:} = 'Vout_B';
                        end
                    end
                end
            end
        end
    end

    ordered_data.ABCD_string = out_labels;

end