clc;
% Initialize variables min_radius, max_radius to set the minimum and maximum radii.
min_radius = 10;
max_radius = 50;

circles = imread("circles.jpg");

[centers, radii] = imfindcircles(circles, [min_radius, max_radius], 'ObjectPolarity', 'dark', 'Sensitivity', 0.9);

% Display the original image
figure(2);
imshow(circles);
hold on;

% Use viscircles to draw the detected circles
viscircles(centers, radii, 'EdgeColor', 'r', 'LineWidth', 5); 

% Hold off to complete drawing
hold off;