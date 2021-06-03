function [] = visualize_2p5d_T(filename, dataset, centroids, plot_dims)
    % VISUALIZE_2P5D_T Visualize a 3D+T dataset as a set of 2D slices changing over time.
    %    MATLAB contains no built-in capabilities to visualize a 3D dataset that
    %    changes with time. It does have independent capabilities for 3D dataset
    %    visualization and 2D+Time (2D+T) dataset visualization. As a workaround,
    %    visualize 2D slices of our 3D dataset in the same figure for each time
    %    slice and compile into a single animated .gif file.

    % Dependencies - Image Processing Toolbox (imshow, viscircles, imwrite, frame2im) 
    
    % Check the plot dimensions for subplot are valid
    assert(all(size(plot_dims) == [1, 2]));

    % Generate large table that maps cell IDs to a random but time invariant color
    color_table = rand(1000, 3);

    delay = 0.3; % Time per GIF frame
    for time_slice = 1:size(dataset, 4)

        % Generate a frame of our GIF
        f = figure;
        set(gcf, 'Visible', 'off') % Hide plots from Live Script output
        set(gcf, 'Position', [0, 0, 1920, 1080]); % Render in 1080p
        for n_plot = 1:size(dataset, 3) % Iterate over all Z slices

            % Plot the 2D slice into the correct subplot
            subplot(plot_dims(1), plot_dims(2), n_plot);
            imshow(double(dataset(:,:,n_plot,time_slice)));
            title(sprintf("Z index = %d", n_plot));

            % If there are centroids, show them with viscircles
            if ~isempty(centroids)
                for i = 1:size(centroids{time_slice}, 2)
                    color = color_table(centroids{time_slice}(i).ID, :);
                    centroid_z_idx = round( ...
                        centroids{time_slice}(i).centroid(3));
                    if centroid_z_idx == n_plot
                        viscircles( ...
                            round(centroids{time_slice}(i).centroid(1:2)), ...
                            9, 'Color', color);
                    else
                        viscircles( ...
                            round(centroids{time_slice}(i).centroid(1:2)), ...
                            3, 'Color', color);
                    end
                end
            end

        end

        % Compile this figure into an image and add it to the .gif
        frame = getframe(f);
        im = frame2im(frame);
        [A,map] = rgb2ind(im,256);
        if time_slice == 1
            imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',delay);
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',delay);
        end
        close(f); % No need to show image in live script

    end
end
