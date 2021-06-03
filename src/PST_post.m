%Dependencies - Image Processing Toolbox (medfilt3)

function [volume_edges] = PST_post(volume_pst_features, handles)

    % Median filter the image to remove speckles inside cells
    % Multiple passes - small sections go to zero over several passes
    med_filtered = volume_pst_features;
    for pass = 1:1 % Tune down to a single median filter pass
        med_filtered = medfilt3(med_filtered, ...
            [5, 5, 3], 'replicate'); % (5,5,3) kernel, extend edges
    end
    
    % Threshold the phase output from the PST to find sharp transitions
    volume_edges_analog = med_filtered ./ max(med_filtered, [], [1,2]);
    volume_edges = volume_edges_analog > handles.Post_Threshold;
end
