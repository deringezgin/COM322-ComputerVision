clc;

zebra = imread("zebra.jpg"); % Read the original image and convert to grayscale
gray_zebra = rgb2gray(zebra);

% Perform Canny edge detection
edges = edge(gray_zebra, 'canny', [0.1, 0.3]);

double_zebra = im2double(zebra);

% Convert the original image to double and highlight the edges
red_edges = double_zebra;
red_edges = red_edges(:, :, :) .* ~edges;
red_edges(:, :, 1) = red_edges(:, :, 1) + edges;


se = strel('disk', 2);
thick_edges = imdilate(edges, se);
colors = [0, 0, 1];
for c = 1:3
    channel = double_zebra(:, :, c);
    channel(thick_edges) = colors(c);
    double_zebra(:, :, c) = channel;
end

figure;
subplot(1, 3, 1); imshow(zebra); title('Original Image');
subplot(1, 3, 2); imshow(red_edges); title('Edges Highlighted in Red');
subplot(1, 3, 3); imshow(double_zebra); title('Bold Highlighted Image')

