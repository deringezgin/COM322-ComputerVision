clc;
hough_start();

function hough_start
    % Saving the image names
    fn{1} = 'line_1.jpg'; 
    fn{2} = 'line_2.jpg';
    fn{3} = 'line_3.jpg';
    fn{4} = 'line_4.jpg';
    fn{5} = 'line_5.jpg';
    fn{6} = 'line_6.jpg';
    fn{7} = 'line_7.jpg';
    fn{8} = 'line_8.jpg';
    fn{9} = 'line_9.jpg';

    % For each image
    for i = 1 : length(fn)
        image1 = imread(fn{i});

        % Show the image
        figure(1);
        subplot(1,3,1);
        imshow(image1);
        title("Original Image");

        % Convert the image into BW for edge detection
        bw_image = rgb2gray(image1);
        
        % Canny Edge Detection
        detected = edge(bw_image, 'canny', [0.1, 0.3]);

        % Showing the Detected Edges in the Image
        subplot(1,3,2);
        imshow(detected);
        title("Detected Edges");

        % Setting up the Accumulator Matrix
        [x_dim, y_dim] = size(detected);  % Getting the size of the image 
        
        % Getting the D value which is the diagonal image pixels
        D = sqrt(x_dim^2 + y_dim^2);
        
        % Ranges for the Theta which is the slope of the line
        theta_range = -89:90;

        % Ranges for Rho which ranges from -D to D
        rho_range = -D:D; 
        
        % Creating the accumulator array
        A = zeros(length(rho_range), length(theta_range)); 

        % For each pixel in the detected edges
        for x = 1:x_dim
            for y = 1:y_dim
                if detected(y, x) % If it is an edge pixel
                    % Loop over all theta values to assess all possible angles
                    for theta_index = 1:length(theta_range)
                        theta = theta_range(theta_index);
                        
                        % Calculate rho for current (x, y) and theta
                        rho = x * cosd(theta) + y * sind(theta);
                        
                        % The rho value can range from -D to D and to ensure that we don't have a negative index, we need this
                        rho_index = round(rho + D);
                        
                        % When we know the exact location, just increment the relevant location.
                        A(rho_index, theta_index) = A(rho_index, theta_index) + 1;
                    end
                end
            end
        end

        neighborhood_size = 20;  % Neighborhood size to set zero
        threshold = 0.39;  % Setting the threshold
        threshold = threshold * 255;  % I like to keep the threshold from 0 to 1 so this updates to 0 to 255

        % Finding the line locations in the image
        [row_peaks, col_peaks] = find_lines(A, neighborhood_size, threshold);

        % Drawing the lines
        subplot(1,3,3);
        imshow(image1);
        title("Detected Lines");
        hold on;

        % For each detected peak
        for p = 1:length(row_peaks)
            % Getting indexes of the matches
            rho_index = row_peaks(p);
            theta_index = col_peaks(p);
            
            % Getting the specific rho and theta values
            rho = rho_range(rho_index);
            theta = theta_range(theta_index);
            
            % Calling the helper draw line function
            draw_line(image1, rho, theta);
        end
        hold off;

        pause;
    end
end

function [row_peaks, col_peaks] = find_lines(A, neighborhood_size, threshold)
    % Initialize outputs
    row_peaks = [];
    col_peaks = [];

    % Loop while there are values in A above the threshold
    while true
        % Find the global maximum in the accumulator array
        max_value = max(A(:));
        
        % If the maximum value is below the threshold, stop
        if max_value < threshold
            break;
        end
        
        % Find the indices of the global maximum
        [row, col] = find(A == max_value, 1, 'first');  % Pick the first maximum if there are multiple

        % Add the peak to the list of row and column peaks
        row_peaks = [row_peaks; row];
        col_peaks = [col_peaks; col];

        % Checking out of index situations
        row_start = max(1, row - neighborhood_size);
        row_end = min(size(A, 1), row + neighborhood_size);
        col_start = max(1, col - neighborhood_size);
        col_end = min(size(A, 2), col + neighborhood_size);
        
        % Set the neighborhood to zero
        A(row_start:row_end, col_start:col_end) = 0;
    end
end

% Function to draw a line on the image given rho and theta
function draw_line(image, rho, theta)
    [rows, ~, ~] = size(image);
    if abs(sind(theta)) > 0 % If the line is not vertical
        y1 = 1;
        x1 = (rho - y1 * sind(theta)) / cosd(theta);
        y2 = rows;
        x2 = (rho - y2 * sind(theta)) / cosd(theta);
    else % If the line is vertical
        x1 = rho / cosd(theta);
        x2 = x1;
        y1 = 1;
        y2 = rows;
    end
    
    % Plotting the line
    line([x1, x2], [y1, y2], 'Color', [1, 0.5, 0], 'LineWidth', 4);
end
