function [centroids] = find_cells(volume_edges, sigmas, z_scale)
    % FIND_CELLS Finds cell centroids and volumes.
    %   Given an edge map derived from the PST, find a single centroid and measure
    %   of volume per cell as an array of structs.

    % Convert edges back to doubles if binarized
    volume_edges = double(volume_edges);

    % Calculate the scale space and binarize
    % Why are we using the edges for this?
    scale_space = dog3( ...
        volume_edges, sigmas, z_scale);
    thresh = 0.5; % Tune so there is one blob per cell
    scale_space(scale_space <  thresh) = 0;
    scale_space(scale_space >= thresh) = 1;

    % Estimate several centroids per cell as starting points using MATLAB builtins
    starting_centroids = cell(1, size(scale_space, 4));
    for i = 1:size(scale_space, 4)
        % Find the connected components and their centroids
        cc = bwconncomp(scale_space(:,:,:,i), 4);
        stats = regionprops(cc, 'Centroid');
        starting_centroids{i} = cat(1, stats.Centroid);
    end
    starting_centroids = cell2mat(starting_centroids');
    starting_centroids = round(starting_centroids);

    % Calculate the second-pass centroid locations and cell volume from
    % the connected components starting from the first pass cell centroid
    refined_centroids = cell(size(volume_edges, 3), size(starting_centroids, 1));
    cell_sizes_vx = cell(size(volume_edges, 3), size(starting_centroids, 1));

    for z_idx = 1:size(volume_edges, 3)
        BW1 = volume_edges(:,:,z_idx) > 0;
        for cent_idx = 1:size(starting_centroids, 1)
            
            % Fill holes in the image then perform a 'photoshop bucket
            % fill' from the starting centroid. Difference to find the
            % pixels filled in.
            closed = imclose(BW1, 5);
            start_point = round(starting_centroids(cent_idx, [2,1]));
            BW2 = imfill(closed, start_point);
            BWdiff = BW2 - BW1;
            
            % Generate the number of pixels changed and, if reasonable, add to
            % the list
            min_pixels_changed = 100; % Chosen at random, tweak if we have trouble detecting small cells
            max_pixels_changed = numel(BW1) / 2; % No cell is taking up half the image
            [rpoints, cpoints] = find(BWdiff); % Diff images and get row/col points
            if (length(rpoints) < min_pixels_changed || length(rpoints) > max_pixels_changed)
                continue; % Something funky is going on, skip this fill
            end
            BW1 = BW2; % Use the filled image here, so we don't re-fill cells for duplicate centroids

            % Looks good, find its center and add it to the list but leave
            % Z centroid as -1 for now
            refined_centroids{z_idx, cent_idx} = [ ... % Centroid in (x, y, z) coords
                mean(cpoints), mean(rpoints), ...
                round(starting_centroids(cent_idx, 3))];
            cell_sizes_vx{z_idx, cent_idx} = length(rpoints);
        end
    end
    
    % Cleanup the cells containing centroids and volumes and matrices
    refined_centroids(cellfun('isempty', refined_centroids)) = [];
    cell_sizes_vx(cellfun('isempty', cell_sizes_vx)) = [];
    
    % Deduplicate detected centroids, most will be duplicated along Z axis
    % so use KNN search then filter out anything further than (max Z dist *
    % 4) away
    cents = reshape(cell2mat(refined_centroids), 3, [])';
    sizes = cell2mat(cell_sizes_vx);
    for i = 1:length(refined_centroids)
        if isempty(refined_centroids{i})
            continue;
        end
        % Search for close centroids, assume max one detection per Z layer
        [idx, dists] = knnsearch( ...
            cents, refined_centroids{i}, 'K', size(volume_edges, 3));
        distance_threshold = size(volume_edges, 3) * 4; % Arbitrary
        dist_mask = dists < distance_threshold;
        new_centroid = mean(cents(idx(dist_mask), :), 1);
        new_cell_size = mean(sizes(idx(dist_mask)));
        indices_to_delete = idx(dist_mask);
        for j = 1:length(indices_to_delete)
            refined_centroids{indices_to_delete(j)} = [];
            cell_sizes_vx{indices_to_delete(j)} = [];
        end
        refined_centroids{i} = new_centroid;
        cell_sizes_vx{i} = new_cell_size;
    end
    
    % Cleanup the cells containing centroids and volumes and matrices #2
    refined_centroids(cellfun('isempty', refined_centroids)) = [];
    cell_sizes_vx(cellfun('isempty', cell_sizes_vx)) = [];
    
    % Add to our centroids for this time slice
    centroids = struct( ...
        'centroid', refined_centroids, ...
        'cell_size_vx', cell_sizes_vx, ...
        'ID', -1); % ID is set later
end

