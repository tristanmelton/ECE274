%% Automatic 2D/3D version of PST
function [features, kernel] = PST_ND(image, handles)
    % The PST, or Phase Stretch Transform, is an operator that finds features
    % of an image. PST takes an intensity image I as its input, and returns a
    % a gray scale image with higher intensities indicating sharper transitions.
    %
    % In the PST, the image is first filtered by passing through a smoothing
    % filter followed by application of a nonlinear frequency-dependent phase
    % described by the PST phase kernel. The output of the transform is the
    % phase in the spatial domain. The main step is the N-D phase function (PST
    % phase kernel) which is typically applied in the frequency domain.  The
    % amount of phase applied to the image is frequency dependent with higher
    % amount of phase applied to higher frequency features of the image. Since
    % sharp transitions, such as edges and corners, contain higher frequencies,
    % PST emphasizes the edge information. Features can be further enhanced by
    % applying thresholding and morphological operations.  For more information
    % please visit: https://en.wikipedia.org/wiki/Phase_stretch_transform
    %
    % [features, kernel] = PST_ND(I, handles) takes the original image I and
    % applies PST to it. PST kernel paramters are given using a handle
    % variable:
    %
    % handles.LPF            : Gaussian low-pass filter Full Width at Half Maximum (FWHM) (min : 0, max : 1)
    % handles.Phase_strength : PST  kernel Phase Strength (min : 0, max : 1)
    % handles.Warp_strength  : PST Kernel Warp Strength (min : 0, max : 1)
    %
    % Class Support
    % -------------
    % I is a double precision 2D or 3D array. features is a double matrix of
    % the same shape as I.
    %
    % Remarks
    % -------
    % The image processing toolbox is needed to run this function, and is
    % compatible with MATLAB R2018b or newer for the support of N-D maximum
    % max(data, [], 'all');
    %
    % Example
    % -------
    % Example 1: Find the features of the circuit.tif image using PST method:
    %
    %    I = imread('circuit.tif');
    %    I=double(I);
    %    handles.LPF=0.21;
    %    handles.Phase_strength=0.48;
    %    handles.Warp_strength=12.14;
    %    handles.Thresh_min=-1;
    %    handles.Thresh_max=0.004;
    %    [features, PST_Kernel]= PST(I, handles);
    %    figure, imshow(features)
    %
    % Copyright
    % ---------
    % PST function  is developed in Jalali Lab at University of California, Los
    % Angeles (UCLA).  PST is a spin-off from research on the photonic time
    % stretch technique in Jalali lab at UCLA.  More information about the
    % technique can be found in our group website:
    % http://www.photonics.ucla.edu This function is provided for research
    % purposes only. A license must be obtained from the University of
    % California, Los Angeles for any commercial applications. The software is
    % protected under a US patent.
    % Citations:
    % 1. M. H. Asghari, and B. Jalali, "Edge detection in digital images using dispersive phase stretch," International Journal of Biomedical Imaging, Vol. 2015, Article ID 687819, pp. 1-6 (2015).
    % 2. M. H. Asghari, and B. Jalali, "Physics-inspired image edge detection," IEEE Global Signal and Information Processing Symposium (GlobalSIP 2014), paper: WdBD-L.1, Atlanta, December 2014.
    % 3. M. Suthar, H. Asghari, and B. Jalali, "Feature Enhancement in Visually Impaired Images", IEEE Access 6 (2018): 1407-1415.
    % 4. Y. Han, and B. Jalali, "Photonic time-stretched analog-to-digital converter: Fundamental concepts and practical considerations", Journal of Lightwave Technology 21, no. 12 (2003): 3085.

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
