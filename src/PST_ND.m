%% Automatic 2D/3D version of PST
function [features, kernel] = PST_ND(image, handles)

    % Get image shape and dimensions
    image_size = size(image);
    ndims = length(image_size);
    assert(ndims == 2 || ndims == 3); % 2D and 3D supported

    % Kernel: magnitude of grid of +/- 0.5 in all dimensions
    L = 0.5;
        
    if ndims == 2
        [X, Y] = ndgrid( ...
            linspace(-0.5, 0.5, image_size(1)), ...
            linspace(-0.5, 0.5, image_size(2)));
        rho = sqrt(X.^2 + Y.^2);
    elseif ndims == 3
        [X, Y, Z] = ndgrid( ...
            linspace(-0.5, 0.5, image_size(1)), ...
            linspace(-0.5, 0.5, image_size(2)), ...
            linspace(-0.5, 0.5, image_size(3)));
        rho = sqrt(X.^2 + Y.^2 + Z.^2);
    end

    % Lowpass filter applied to reduce noise
    image_f = fftn(image);
    sigma = (handles.LPF)^2 / log(2);
    image_f = image_f .* fftshift(exp(-(rho/sqrt(sigma)).^2));
    image = real(ifftn(image_f));

    % Construct the PST kernel in the frequency domain
    kernel = rho*handles.Warp_strength .* atan(rho*handles.Warp_strength) ...
        - log(1+(rho*handles.Warp_strength).^2)/2;
    kernel = kernel / max(kernel, [], 'all') * handles.Phase_strength;

    % Apply the PST kernel in the frequency domain, IFFT, calculate phase
    image_f = fftn(image) .* fftshift(exp(-1j * kernel));
    features = angle(ifftn(image_f));

end
