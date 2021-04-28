%% Threshold the phase output from the PST to find sharp transitions
function [edges] = PST_post(image, features, handles)

    edges = zeros(size(features));
    edges(features > handles.Thresh_max) = 1;
    edges(features < handles.Thresh_min) = 1;
    edges(image < (max(image, [], 'all') * handles.Thresh_dark)) = 0;

end
