function [volume_edges] = PST_post(volume_pst_features, handles)
    % Threshold the phase output from the PST to find sharp transitions
    volume_edges_analog = volume_pst_features ./ max(volume_pst_features, [], [1,2]);
    volume_edges = volume_edges_analog > handles.Post_Threshold;
end
