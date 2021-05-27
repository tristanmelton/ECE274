function [scale_space] = dog3(image_gray, sigmas, z_scale)
    % Calculates the scale space of a grayscale image using the Difference
    % of Gaussians method (SIFT preprocessor)
    % sigmas should be an array of positive sigma values for each blur
    % performed.
    %
    % Example:
    % scale_space = dog3(image, [4, 9, 16, 25, 36, 49, 64]);

    % Set up our output vector for gaussian blurs
    [size_x, size_y, size_z] = size(image_gray);
    blurs = zeros(size_x, size_y, size_z, length(sigmas));
    
    % Perform blurs and place into array
    sigmas_hl = fliplr(sigmas);
    for i = 1:length(sigmas_hl)
        blurs(:,:,:,i) = imgaussfilt3(image_gray, ...
            [sigmas_hl(i), sigmas_hl(i), sigmas_hl(i) / z_scale]);
    end
    
    % Scale space is difference across sigmas
    scale_space = diff(blurs, 1, 4); % Difference across last dimension (4)
    scale_space = flip(scale_space, 4); % Fix diff ordering
    
    % Optional: Normalize each layer of scale space for better visualization
    for i = 1:size(scale_space, 4)
        scale_space = scale_space / max(abs(scale_space(:,:,:,i)), [], 'all');
    end
end

