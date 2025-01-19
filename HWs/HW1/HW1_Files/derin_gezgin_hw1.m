% Derin Gezgin
% COM322: Computer Vision | Fall 2024 | Homework #1
% Due October 6th, 2024
% File that contains the functions that has the code for homework. 
clc;  
main();

function [] = main()
    % Cropping regions of interest for eye, mouth and nose
    fn = dir('faces/*.jpg');
    eye_roi = imread(strcat(fn(10).folder, '/', fn(10).name));
    eye_roi = eye_roi(82:100, 15:60);
    mouth_roi = imread(strcat(fn(4).folder, '/', fn(4).name));
    mouth_roi = mouth_roi(135:165, 35:95);
    nose_roi = imread(strcat(fn(10).folder, '/', fn(10).name));
    nose_roi = nose_roi(70:130, 42:87);

    % Calling the problem_1 function to detect and show eye, mouth and nose.
    problem_1(eye_roi);
    problem_1(mouth_roi);
    problem_1(nose_roi);

    % Calling the problem_2 for each m&m image
    problem_2(1);
    problem_2(2);
    problem_2(3);
end

function [] = problem_1(roi)
    % Reading the images in the folder
    fn = dir('faces/*.jpg');
    
    % Number of rows and columns of the final output
    num_columns = 5; 
    num_rows = 4;
    row_count = 0;

    roi_height = size(roi, 1);  
    roi_width = size(roi, 2);

    image_row = [];
    combined_image = [];  % The big image we will return the combined image
    
    for image_idx = 1:num_rows * num_columns
        % For each image in the folder read the image
        image = imread(strcat(fn(image_idx).folder, '/', fn(image_idx).name));
        
        % Calculate normxcorr2 on the whole image but only get the best result
        c = normxcorr2(roi, image);
        [ypeak, xpeak] = find(c == max(c(:)));
    
        % Getting the top left corner of the detected area
        x_left = max(xpeak - roi_width + 1, 1);
        y_top = max(ypeak - roi_height + 1, 1);
    
        % Insert the shape to the image
        image_with_rectangle = insertShape(image, 'Rectangle', [x_left, y_top, roi_width, roi_height], 'Color', 'red', 'LineWidth', 4);
    
        % If the row is empty, add the rectangle to the empty row as it'll be the first thing in that row
        if isempty(image_row)
            image_row = image_with_rectangle;
        else
            image_row = [image_row, image_with_rectangle];
        end
    
        % If we added enough images to the row, we have to pass to the next row
        if mod(image_idx, num_columns) == 0
            if isempty(combined_image)
                combined_image = image_row;
            else
                combined_image = [combined_image; image_row];
            end
            image_row = []; 
        end
    end
    
    % Show the image in a new window
    figure;
    imshow(combined_image);
    pause;
end

function [] = problem_2(num)
    % Reading the image and also the template
    filename = strcat('m&ms/m&m_count', num2str(num), '.png');
    img = imread(filename);
    bw_img = rgb2gray(img);
    fill = imread("m&ms/m&m_blue_template.png");
    roi = rgb2gray(fill);

    % Calculate normxcorr2 on the whole image
    c = normxcorr2(roi, bw_img);
   
    % Variables to keep track of the count
    big_count = 0;
    small_count = 0;
    threshold = 0.6;  % Anything above this threshold will pass

    roi_height = size(roi, 1);
    roi_width = size(roi, 2);
    
    figure(num);
    imshow(bw_img);
    hold on;

    % While there are still points over the threshold
    while max(c(:)) > threshold
        [ypeak, xpeak] = find(c == max(c(:)));  % Get the coordinates

        % Calculating the center and marking it
        x_center = max(xpeak - roi_width / 2, 1);
        y_center = max(ypeak - roi_height / 2, 1);
        plot(x_center, y_center, 'r.', 'MarkerSize', 50, 'LineWidth', 2);
        
        c(ypeak-10:ypeak+10, xpeak-10:xpeak+10) = 0;  % Zeroing the area to not detect the m&m again

        % Replacing the region with fill
        img(ypeak-roi_height+1:ypeak, xpeak-roi_width:xpeak-1, :) = fill;
        big_count = big_count + 1;  % Incrementing the big count
    end
    
    % Resizing roi to be able to detect the smaller m&ms
    % Rest of the process is exactly the same as the previous one
    roi = imresize(roi, 0.5);
    fill = imresize(fill, 0.5);
    c = normxcorr2(roi, bw_img);
    roi_height = size(roi, 1);
    roi_width = size(roi, 2);

    while max(c(:)) > threshold
        [ypeak, xpeak] = find(c == max(c(:)));

        x_center = max(xpeak - roi_width / 2, 1);
        y_center = max(ypeak - roi_height / 2, 1);
        plot(x_center, y_center, 'r.', 'MarkerSize', 30, 'LineWidth', 2);
        
        c(ypeak-10:ypeak+10, xpeak-10:xpeak+10) = 0;

        img(ypeak-roi_height+1:ypeak, xpeak-roi_width:xpeak-1, :) = fill;
        small_count = small_count + 1;
    end

    % Displaying the counts and also showing the final image
    disp("BIG COUNT");
    disp(big_count);
    disp("SMALL COUNT");
    disp(small_count);
    figure;
    imshow(img);
    pause;
    hold off;
end
