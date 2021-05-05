function [scale_space] = dog2(image_gray, sigmas)
    % Calculates the scale space of a grayscale image using the Difference
    % of Gaussians method (SIFT preprocessor)
    % sigmas should be an array of positive sigma values for each blur
    % performed.
    %
    % Example:
    % scale_space = dog2(image, [4, 9, 16, 25, 36, 49, 64]);

    % Set up our output vector for gaussian blurs
    [size_x, size_y] = size(image_gray);
    blurs = zeros(size_x, size_y, length(sigmas));
    
    % Perform blurs and place into array
    sigmas_hl = fliplr(sigmas);
    for i = 1:length(sigmas_hl) % It's 2021, why can't I 'for sigma in sigmas'
        blurs(:,:,i) = imgaussfilt(image_gray, sigmas_hl(i));
    end
    
    % Scale space is difference across sigmas
    scale_space = diff(blurs, 1, 3); % Difference across last dimension (3)
    
    % Optional: Normalize scale space for better visualization
    scale_space = scale_space / max(scale_space, [], 'all');
end

