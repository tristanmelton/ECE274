function [centroids] = track_cells(centroids)
    % TRACK_CELLS Assign centroids consistent IDs across time slices.
    %    Given all detected centroids and areas across all time slices, try to
    %    assign each unique cell a unique integer ID and track it across time
    %    slices using a scoring algorithm that considers euclidean distance and
    %    change in volume over time.

    % Iterate through all given time slices
    n_time_slices = length(centroids);
    n_dims = length(centroids{1}(1).centroid); % Detect 2D/3D distances.
    for time_slice = 1:n_time_slices

        % Track the refined centroids        
        n_curr_centroids = size(centroids{time_slice}, 2);
       
        % On the first pass, just assign monotonically increasing IDs
        if time_slice ==  1
            for j = 1:n_curr_centroids
                centroids{time_slice}(j).ID = j;
            end

        % On all subsequent passes, try to map each observed cell to a most likely
        % cell in the previous time slice.
        else
            % Calculate the distances from every previous centroid to every new
            % one. Use K=5 in the KNN distance function to filter top 5
            % results.
            curr_centroids = reshape( ...
                [centroids{time_slice}.centroid], ...
                n_dims, [])';
            prev_centroids = reshape( ...
                [centroids{time_slice-1}.centroid], ...
                n_dims, [])';
            n_prev_centroids = size(prev_centroids, 1);
            [prev_cell_indices, distances] = knnsearch( ...
                prev_centroids, curr_centroids, 'K', 5);
            
            % Calculate the volume delta associated with each distance
            curr_volumes = [centroids{time_slice}.cell_size_vx]';
            prev_volumes = [centroids{time_slice-1}.cell_size_vx]';
            volume_deltas = double(abs(prev_volumes(prev_cell_indices) - curr_volumes));
            
            % Calculate a weighted score on how likely each of these current
            % cells are to be the previous cell in 'cell_indices'
            % This is pretty arbitrary right now.
            scores = distances + (volume_deltas / 300);
            % Remap scores and indices to process highest confidence cells
            % first
            [~, ind] = sort(sort(scores, 2), 1);
            ind = ind(:,1); % Only need sorting by first col
            prev_cell_indices = prev_cell_indices(ind,:);
            scores = scores(ind,:);
            
            % Iterate over each row (new cell) and map its ID
            for i = 1:n_curr_centroids
                curr_cell_index = ind(i);
                [~, sorting_indices] = sort(scores(i,:));
                ranked_prev_cell_indices = prev_cell_indices(i, sorting_indices);
                for j = 1:length(ranked_prev_cell_indices)
                    proposed_id = centroids{time_slice-1}(ranked_prev_cell_indices(j)).ID;
                    % Deduplication check
                    if any([centroids{time_slice}.ID] == proposed_id)
                        continue;
                    end
                    centroids{time_slice}(curr_cell_index).ID = proposed_id;
                    break;
                end
            end
                
            % Label remaining -1s as new cells
            highest_index = max([centroids{time_slice}.ID]);
            for i = 1:n_curr_centroids
                if (centroids{time_slice}(i).ID == -1)
                    highest_index = highest_index + 1;
                    centroids{time_slice}(i).ID = highest_index;
                end
            end
        end
    end
end

