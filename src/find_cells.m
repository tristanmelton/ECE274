function [centroids] = find_cells(volume_edges)
    % FIND_CELLS Finds cell centroids and volumes.
    %   Given an edge map derived from the PST, find a single centroid and measure
    %   of volume per cell as an array of structs.

    % Convert edges back to doubles
    volume_edges = double(volume_edges);

    % Calculate the scale spaces of our edges and use for first-pass centroid
    % detection
    sigmas = [10, 15, 20, 25];

    % Calculate the scale space and binarize
    % Why are we using the edges for this?
    scale_space = dog3( ...
        volume_edges, sigmas);
    thresh = 0.5; % Tune so there is one blob per cell
    scale_space(scale_space <  thresh) = 0;
    scale_space(scale_space >= thresh) = 1;

    % Estimate several centroids per cell as starting points using MATLAB builtins
    starting_centroids = cell(1, size(scale_space, 4));
    for i = 1:size(scale_space, 4)
        % Find the connected components and their centroids
        cc = bwconncomp(scale_space(:,:,:,i), 18);
        stats = regionprops(cc, 'Centroid');
        starting_centroids{i} = cat(1, stats.Centroid);
    end
    starting_centroids = cell2mat(starting_centroids');
    starting_centroids = round(starting_centroids);

    % Quick plot of the starting centroid locations
%     figure;
%     imshow(volume_edges(:,:,1));
%     title('Detected Starting Centroids');
%     radii = ones(size(starting_centroids, 1), 1) * 1;
%     viscircles(starting_centroids(:,[1,2]), radii);

    % Calculate the second-pass centroid locations and cell volume from
    % the connected components starting from the first pass cell centroid
    refined_centroids = cell(size(volume_edges, 3)/5, size(starting_centroids, 1));
    cell_sizes_vx = cell(size(volume_edges, 3)/5, size(starting_centroids, 1));

    % For now only work on a 2D slice
    single_slices = volume_edges(:,:,1:5:size(volume_edges, 3));
    starting_cents_sliced = starting_centroids;
    starting_cents_sliced(:, [3]) = ceil(starting_cents_sliced(:, [3])/5);

    for slice = 1:size(single_slices, 3)
        BW1 = single_slices(:,:,slice) > 0;
        for i = 1:size(starting_cents_sliced, 1)

            closed = imclose(BW1, 5);
            BW2 = imfill(closed, round(starting_cents_sliced(i, [2,1])));
            BWdiff = BW2-BW1;
            % Generate the number of pixels changed and, if reasonable, add to
            % the list
            min_pixels_changed = 100; % Chosen at random, tweak if we have trouble detecting small cells
            max_pixels_changed = numel(BW1) / 2; % No cell is taking up half the image
            [rpoints, cpoints] = find(BWdiff); % Diff images and get row/col points
            if (length(rpoints) < min_pixels_changed || length(rpoints) > max_pixels_changed)
                continue; % Something funky is going on, skip this fill
            end
            BW1 = BW2; % Use the filled image here, so we don't re-fill cells for duplicate centroids

            % Looks good, find its center and add it to the list
            refined_centroids{slice, i} = [mean(cpoints), mean(rpoints)]; % Centroid in (x, y) coords
            cell_sizes_vx{slice, i} = length(rpoints);
        end
    end
%     BW1 = volume_edges(:,:,1) > 0;
%     for i = 1:size(starting_centroids, 1)
%
%         % Binarize the 2D image then fill from the starting centroid. Use
%         % the imfill() documentation variable names for clarity
%         % imfill() seems to use y,x indexing rather than x,y
%         closed = imclose(BW1, 5);
%         BW2 = imfill(closed, round(starting_centroids(i, [2,1])));
%         BWdiff = BW2 - BW1;
%
%         % Generate the number of pixels changed and, if reasonable, add to
%         % the list
%         min_pixels_changed = 100; % Chosen at random, tweak if we have trouble detecting small cells
%         max_pixels_changed = numel(BW1) / 2; % No cell is taking up half the image
%         [rpoints, cpoints] = find(BWdiff); % Diff images and get row/col points
%         if (length(rpoints) < min_pixels_changed || length(rpoints) > max_pixels_changed)
%             continue; % Something funky is going on, skip this fill
%         end
%         BW1 = BW2; % Use the filled image here, so we don't re-fill cells for duplicate centroids
%
%         % Looks good, find its center and add it to the list
%         refined_centroids{i} = [mean(cpoints), mean(rpoints)]; % Centroid in (x, y) coords
%         cell_sizes_vx{i} = length(rpoints);
%     end

    % Cleanup the cells containing centroids and volumes and matrices, then
    % add to our centroids for this time slice
    keep = any(~cellfun('isempty',refined_centroids), 1);
    refined_centroids = refined_centroids(:, keep);
    %refined_centroids(cellfun('isempty', refined_centroids)) = [];
    keep = any(~cellfun('isempty',cell_sizes_vx), 1);
    cell_sizes_vx = cell_sizes_vx(:, keep);
    %cell_sizes_vx(cellfun('isempty', cell_sizes_vx)) = [];
    centroids = struct( ...
        'centroid', refined_centroids, ...
        'cell_size_vx', cell_sizes_vx, ...
        'ID', -1); % ID is set later
end

