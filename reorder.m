%% function to assign the names Vout_A, Vout_B, Vout_C, Vout_D

function [ordered_data] = reorder(out_coord)

    out_coord = sortrows(out_coord);
    min_z = min(out_coord(:,3));
    max_z = max(out_coord(:,3));
    min_y = min(out_coord(:,2));
    max_y = max(out_coord(:,2));
    for j = 1:length(out_coord)
        if out_coord(j,3) == max_z
            if out_coord(j,2) == min_y
                out_labels(j,:) = 'Vout_A';
            elseif out_coord(j,2) == max_y
                out_labels(j,:) = 'Vout_C';
            end
        elseif out_coord(j,3) == min_z
            if out_coord(j,2) == min_y
                out_labels(j,:) = 'Vout_B';
            elseif out_coord(j,2) == max_y
                out_labels(j,:) = 'Vout_D';
            end
        end
    end

    ordered_data.final_string = out_labels;
end