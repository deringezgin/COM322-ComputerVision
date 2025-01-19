clc;
% Initialize variables min_radius, max_radius to set the minimum and maximum radii.
min_radius = 10;
max_radius = 50;

% Initialize a variable called threshold to determine qualified peaks in the accumulator array.
threshold = 170;

% Read image, find edge image E, get dimensions y_dim, x_dim.
circles = imread("circles.jpg");
figure(1);
imshow(circles);
hold on;
gray_circles = rgb2gray(circles);
E = edge(gray_circles, 'canny');
[y_dim, x_dim, ~] = size(circles);

% Initialize accumulator array ACC with dimensions y_dim, x_dim, max_radius
ACC = zeros(y_dim, x_dim, max_radius);

% Loop through all pixels in the edge-detected image
for y = 1:y_dim
    for x = 1:x_dim
        if E(y, x) == 1  % If the pixel at (x, y) is an edge
            for radius = min_radius:max_radius
                % Loop through theta values (angles around the circle)
                for theta = 0:360  % Use degrees from 0 to 360
                    % Calculate possible center points using parametric equations
                    xcp = round(x - radius * cosd(theta));
                    ycp = round(y - radius * sind(theta));

                    % Check if the calculated center point is within image bounds
                    if xcp > 0 && xcp <= x_dim && ycp > 0 && ycp <= y_dim
                        % Increment the ACC cell corresponding to (ycp, xcp, radius)
                        ACC(ycp, xcp, radius) = ACC(ycp, xcp, radius) + 1;
                    end
                end
            end
        end
    end
end

for radius = min_radius:max_radius
    for y = 1:y_dim
        for x = 1:x_dim
            if ACC(y, x, radius) > threshold
                % Zero out the neighborhood around the peak
                ACC(max(1, y-5):min(y_dim, y+5), max(1, x-5):min(x_dim, x+5), radius) = 0;

                % Draw the circle on the original image using parametric equations
                theta = linspace(0, 2*pi, 360);  % Create points for drawing the circle
                x_circle = x + radius * cos(theta);
                y_circle = y + radius * sin(theta);

                % Keep the circle within the image bounds
                valid_idx = (x_circle > 0 & x_circle <= x_dim & y_circle > 0 & y_circle <= y_dim);

                % Plot the circle on the original image
                plot(x_circle(valid_idx), y_circle(valid_idx), 'r', 'LineWidth', 2);  % 'r' is red color
            end
        end
    end
end


hold off;


