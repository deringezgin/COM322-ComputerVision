% Derin Gezgin
% COM322: Computer Vision | Fall 2024 | Homework #2
% Due October 14th, 2024
% File that contains the functions that has the code for the single object part of the homework.
% Note: I removed some of your comments to clean up the code. 

clc;
image_framework();

function image_framework
    IMAGE_FILE_TYPE = 'jpg';
    [fg_fn, bg_fn, gt_fn] = get_files_w_bkg(IMAGE_FILE_TYPE);
    num_files = numel(fg_fn);
    
    est_obj_detected = zeros(num_files, 1);
    est_obj_area = zeros(num_files, 1);
    est_obj_area_count = 0;
    est_obj_center = zeros(num_files, 1);
    est_obj_center_count = 0;
    
    for i = 1:num_files
        I_FG = imread(fg_fn{i});
        I_BG = imread(bg_fn{i});

        figure(1);
        subplot(1, 3, 1);
        imshow(I_FG);
        title('Foreground Image');
        
        subplot(1, 3, 2);
        imshow(I_BG);
        title('Background Image');
       
        gt = get_gt(gt_fn{i});   

        fprintf('\n\nProcessing file: %s.', fg_fn{i} );

        % ==== EXAMPLE 1: Check the presence of an object in the image file
        threshold = 0.3; % threshold for size of object as a percentage of the image
        obj_present = estimate_object_present(I_FG, I_BG, threshold);
        est_obj_detected(i) = eval_object_present(obj_present, gt);
        fprintf('\nObject found: %d [GT:%d]', obj_present, gt(1) );
        
        % ==== EXAMPLE 2: Check the area estimate of the object in the image file.
        if obj_present
            threshold = 0.23; % threshold for the pixel difference;
            area = estimate_object_area(I_FG, I_BG, threshold);
            est_obj_area(i) = eval_object_area(area, gt(2));
            est_obj_area_count = est_obj_area_count + 1;
            fprintf('   Area estimate: %d [GT:%d]', area, gt(2) );            
        end
        
        % ==== EXAMPLE 3: Find the coordinates of the center of the object
        if obj_present
            threshold = 0.3; % threshold for the pixel difference;
            [obj_x, obj_y] = estimate_object_center( I_FG, I_BG, threshold);
            est_obj_center(i) = eval_object_center(obj_x, obj_y, gt);
            est_obj_center_count = est_obj_center_count + 1;
            fprintf('   Center: (%d, %d) [GT:(%d, %d)]', obj_x, obj_y, gt(3), gt(4) );
        end
        
    end
    obj_detection_accuracy = 100*sum(est_obj_detected)/num_files;
    obj_area_accuracy = 100*sum(est_obj_area)/est_obj_area_count;
    obj_center_accuracy = 100*sum(est_obj_center)/est_obj_center_count;

    fprintf('\n\n-----------------------------------------\n', obj_detection_accuracy);
    fprintf('Object detection accuracy: %5.1f%% \n', obj_detection_accuracy);
    fprintf('Object area estimation accuracy: %5.1f%%\n', obj_area_accuracy);
    fprintf('Object center estimation accuracy: %5.1f%%\n', obj_center_accuracy);
end

function isObj = estimate_object_present(I_FG, I_BG, threshold)
    % Function to check if there are any objects in the image
    TH = threshold * 255;  % Adjusting the threshold
    diff = sum(abs(double(I_FG)-double(I_BG)),3);  % Calculating the difference
    diff = diff > TH;  % Making it a binary mask 
    A_diff_closed = imclose(diff, strel('disk',3));  % Closing the gaps
    subplot(1,3,3);  % Plotting the extracted object
    imshow(A_diff_closed);
    title('Extracted Object');
    pause;
    if sum(A_diff_closed(:)) > 0  % Returning 1/0 depending on our image
        isObj = 1;
    else
        isObj = 0;
    end
end

function obj_area = estimate_object_area(I_FG, I_BG, threshold)
    % Function to estimate the area of a detected object
    TH = threshold * 255;
    diff = sum(abs(double(I_FG)-double(I_BG)),3);
    diff = diff > TH;
    A_diff_closed = imclose(diff, strel('disk',3));

    obj_area = nnz(A_diff_closed);  % Counting the non-zero elements
end

function [obj_x, obj_y] = estimate_object_center(I_FG, I_BG, threshold)
    % Function to estimate the center of the detected object
    TH = threshold * 255;
    diff = sum(abs(double(I_FG)-double(I_BG)),3);
    diff = diff > TH;
    A_diff_closed = imclose(diff, strel('disk',3));
    
    [rows, cols] = find(A_diff_closed);  % Finding the indices of the rows and cols.
    obj_x = mean(cols);
    obj_y = mean(rows);
end

function present = eval_object_present(obj_present, gt)
    present = obj_present == (gt(1)>0);
end

function degree_of_match = eval_object_area(area, gt_area)
    if area ~= 0
        if gt_area >= area
            degree_of_match = area / gt_area;
        else
            degree_of_match = gt_area / area;               
        end
    else
        degree_of_match = 0;
    end
end

function percentage = eval_object_center(obj_x, obj_y, gt)
    r = (gt(2)/pi)^.5;
    diag = ((obj_x-gt(3))^2 + (obj_y-gt(4))^2)^.5;
    if diag > r
        percentage = 0;
    else
        percentage = 1 - diag/r;
    end 
end

function [fg_fn, bg_fn, gt_fn] = get_files_w_bkg(im_type)
    fg_fn = {};
    bg_fn = {};
    gt_fn = {};
    fg_imgs = dir ( strcat( 'images/*frg.', im_type) );
    for i = 1:numel(fg_imgs)
        fg_fn{i} = ['images/' fg_imgs(i).name];
        stem = fg_fn{i}(1:end-7);
        bg_fn{i} = [stem 'bkg.' im_type]; 
        gt_fn{i} = [stem '.txt']; 
    end
end

function content = get_gt(txtfile)
    fileID = fopen(txtfile, 'r');
    content = fscanf(fileID, '%d');
    fclose(fileID);
end
