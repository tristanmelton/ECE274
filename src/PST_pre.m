function [volume] = PST_pre(volume, handles)
    % Increase the contrast of the PST input to better find edges in dark
    % parts of the image.

    % Suppress dark noise, setting to 0 caused issues with histogram eq
    volume(volume < 0.1) = 0.002; 

    % Average, median, histogram to boost contrast
    for z_idx = 1:size(volume, 3)
        volume(:,:,z_idx) = filter2( ...
            fspecial('average', 2), volume(:,:,z_idx));
        volume(:,:,z_idx) = medfilt2( ...
            volume(:,:,z_idx));
        volume(:,:,z_idx) = adapthisteq( ...
            volume(:,:,z_idx), 'ClipLimit', 0.05);
    end

    % Take a second stage to try to reduce noise in between cells
    volume(volume < 0.25) = 0.002;
end

