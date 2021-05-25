function [] = visualize_2p5d_T(filename, dataset, centroids, plot_dims)
    % VISUALIZE_2P5D_T Visualize a 3D+T dataset as a set of 2D slices changing over time.
    %    MATLAB contains no built-in capabilities to visualize a 3D dataset that
    %    changes with time. It does have independent capabilities for 3D dataset
    %    visualization and 2D+Time (2D+T) dataset visualization. As a workaround,
    %    visualize 2D slices of our 3D dataset in the same figure for each time
    %    slice and compile into a single animated .gif file.

    % Check the plot dimensions for subplot are valid
    assert(all(size(plot_dims) == [1, 2]));

    % Generate large table that maps cell IDs to a random but time invariant color
    color_table = rand(1000, 3);

    delay = 0.3; % Time per GIF frame
    for time_slice = 1:size(dataset, 4)

        % Generate a frame of our GIF
        % ct = 0;
        f = figure;
        set(gcf, 'Visible', 'off') % Hide plots from Live Script output
        set(gcf, 'Position', [0, 0, 1920, 1080]); % Render in 1080p
        for n_plot = 1:size(dataset, 3) % Iterate over all Z slices

            % Plot the 2D slice into the correct subplot
            subplot(plot_dims(1), plot_dims(2), n_plot);
            title(sprintf("Z index = %d", n_plot));
            imshow(dataset(:,:,n_plot,time_slice));

            % If there are centroids, show them with viscircles
            if ~isempty(centroids)
                for i = 1:size(centroids{time_slice}, 2)
                    % if ceil(centroids{time_slice}(i).cell_z) == ngif
                    viscircles(centroids{time_slice}(i).centroid, 7, ...
                        'Color', color_table(centroids{time_slice}(i).ID,:));
                    % ct = ct + 1;
                    % end
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

        % Second plot with all centroids together. This is deprecated by the
        % above, can I delete this @Tristan?

        % f2 = figure;
        % set(gcf,'Visible', 'off') % Hide plots from Live Script output
        % imshow(dataset(:,:,1,time_slice));
        % for i = 1:size(centroids{time_slice}, 2)
        % viscircles(centroids{time_slice}(i).centroid, 7, ...
        %     'Color', color_table(centroids{time_slice}(i).ID,:));
        % end
        % frame = getframe(f2);
        % im = frame2im(frame);
        % [A,map] = rgb2ind(im,256);
        % name = 'cell_track_flat.gif';
        % if time_slice == 1
        %     imwrite(A, map,name,'gif','LoopCount',Inf,'DelayTime',delay);
        % else
        %     imwrite(A, map,name,'gif','WriteMode','append','DelayTime',delay);
        % end
        % close(f2); % No need to show image in live script

    end
end
