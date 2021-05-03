function [data] = dataset(root_folder)
    % Imports a Cell Tracking dataset by root folder. Assumes all images
    % to be of the format tXXX.tif. Generates MxNx1xT tensor compatible with
    % implay(). Make sure to leave '/' at the end of root_folder.
    
    % Get number of images in the folder and read the first image to get
    % the shape
    n_images = length(dir(root_folder)) - 2; % skip '.', '..'. TODO: filter?
    first_image_path = strcat(root_folder, 't000.tif');
    xy_dims = size(imread(first_image_path));
    z_dim = length(imfinfo(first_image_path));
    
    % Set up an appropriately shaped tensor and load each file into it
    data = zeros(xy_dims(1), xy_dims(2), z_dim, n_images, 'uint8');
    for i = 1:n_images
        filename = sprintf("t%03d.tif", i-1);
        image_path = strcat(root_folder, filename);
        for j = 1:z_dim
            data(:,:,j,i) = imread(image_path, j);
        end
    end
end

