% Computes a Difference oOf Gaussians filter.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
fontSize = 20;

% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
button = menu('Use which demo image?', 'CameraMan', 'Moon', 'Eight', 'Coins');
if button == 1
	baseFileName = 'cameraman.tif';
elseif button == 2
	baseFileName = 'moon.tif';
elseif button == 3
	baseFileName = 'eight.tif';
else
	baseFileName = 'coins.png';
end
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% File doesn't exist -- didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
grayImage = imread(fullFileName);
% Get the dimensions of the image.  
% numberOfColorBands should be = 1.
[rows columns numberOfColorBands] = size(grayImage);
% Display the original gray scale image.
subplot(2, 2, 1);
imshow(grayImage, []);
title('Original Grayscale Image', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Give a name to the title bar.
set(gcf,'name','Demo by ImageAnalyst','numbertitle','off') 

% Let's compute and display the histogram.
[pixelCount grayLevels] = imhist(grayImage);
subplot(2, 2, 2); 
bar(pixelCount);
grid on;
title('Histogram of Original Image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.

gaussian1 = fspecial('Gaussian', 21, 15);
gaussian2 = fspecial('Gaussian', 21, 20);
dog = gaussian1 - gaussian2;
dogFilterImage = conv2(double(grayImage), dog, 'same');
subplot(2, 2, 3); 
imshow(dogFilterImage, []);
title('DOG Filtered Image', 'FontSize', fontSize);

% Let's compute and display the histogram.
[pixelCount grayLevels] = hist(dogFilterImage(:));
subplot(2, 2, 4); 
bar(grayLevels, pixelCount);
grid on;
title('Histogram of DOG Filtered Image', 'FontSize', fontSize);

