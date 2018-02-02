% Image Processing Course / Term Project
% 08.12.2017
% Abdülhakim Gültekin - Gebze Technical University

% This algorithm is generated for the images which have been added to the 
% same folder and have similar properties. As for an arbitrary 
% image there should be a specific algorithm to meet its needs for 
% detection, this algorithm may need to be improved or changed regarding
% interested images' properties.

clc, clearvars, close all;
%% image acquisition and converting to grayscale
f = rgb2gray(imread('tr_hard1.jpg'));

figure, imshow(f), title('Gray Scaled Image');
%% pre-process
% gamma correction to light up the image
f = imadjust(f,[],[],0.5);

figure, imshow(f), title('Image after Gamma Correction ');

% smoothing the image to remove noise 
mask = ones(5) / (25);
f_smooth = imfilter(f,mask);

figure, imshow(f_smooth), title('Smoothed Image');
%% edge detection
% Edge detection is done by using Sobel operator.
% a hands-on way
%
% sobelX = [-1 -2 -1; 0 0 0; 1 2 1];
% sobelY = sobelX';
% gx = imfilter(f_smooth, sobelX);
% gy = imfilter(f_smooth, sobelY);
% f_edge = abs(gx) + abs(gy);
%
% an alternative way
f_edge = edge(f_smooth, 'Sobel');

figure, imshow(f_edge), title('Edges by Sobel');
%% thresholding
% Since we choose the second way at previous part, thresholding is not
% needed. Comment thresholding part then run the code again.
f_edge = im2uint8(f_edge);
level = graythresh(f_edge);
f_th  = imbinarize(f_edge, level);

figure, imshow(f_th), title('Image Thresholded');
%% morphological process
% creating structuring elements
se1 = strel('rectangle', [15 40]);
se2 = strel('rectangle', [15 10]);

% Closing is applied to close spaces between correlated parts of edges.
f_close = imclose(f_th,se1);

figure, imshow(f_close), title('Closed Image');

% Opening is applied to remove wrong connections and unwanted objects.
f_open = imopen(f_close,se2);

figure, imshow(f_open), title('Opened Image');
%% connected component analysis
cc1 = bwconncomp(f_open);
% Feature extracting so as to find interested components. Notice that the
% 'eccentricity' property is not used on this application but added into
% code.
stats1 = regionprops(cc1, {'Area','Eccentricity'});
area = [stats1.Area];
sumArea = 0;
% ecc = [stats1.Eccentricity];
% sumEcc = 0;

for i = 1 : cc1.NumObjects
    sumArea = sumArea + area(i);
    % sumEcc = sumEcc + ecc(i);
end

avArea= sumArea / cc1.NumObjects;
% avEcc = sumEcc / cc1.NumObjects;

% Take the components which have an area larger than 25 percent of
% the average.
idx = find([stats1.Area] > (avArea * 1 / 4)); 
BW = ismember(labelmatrix(cc1), idx);

figure, imshow(BW), title('Binary Image of Interested Components');

% label binary image to get 'BoundingBox' properties of interested
% components
cc2 = bwconncomp(BW);
stats2 = regionprops(cc2, 'BoundingBox');
%% representation
figure, imshow(f), title('Detected Vehicles');

% represent each detected component with a rectangular 
for i = 1 : cc2.NumObjects
rectangle('Position', stats2(i).BoundingBox, ...
    'EdgeColor','r','LineWidth',2);
end