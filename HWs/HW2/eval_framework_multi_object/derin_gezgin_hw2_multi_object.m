% Derin Gezgin
% COM322: Computer Vision | Fall 2024 | Homework #2
% Due October 14th, 2024
% File that contains the functions that has the code for the multiple-objects part of the homework.
% Note: I removed some of your comments to clean up the code. 

clc;
image_framework();

function image_framework
    IMAGE_FILE_TYPE = 'jpg';
    
    [fg_fn, bg_fn, gt_fn] = get_files_w_bkg(IMAGE_FILE_TYPE);
    num_files = numel(fg_fn);
    
    est_obj_count_measure = zeros(num_files, 1);
    
    for i = 1:num_files
        I_FG = imread(fg_fn{i});
        figure(1);
        subplot(1, 3, 1);
        imshow(I_FG);
        title("Foreground Image");

        I_BG = imread(bg_fn{i});
        
        subplot(1, 3, 2);
        imshow(I_BG);
        title("Background Image");
       
        gt = get_gt(gt_fn{i});   
        
        fprintf('Processing file: %s.', fg_fn{i} );
        
        count = estimate_object_count(I_FG, I_BG, 0.6);  % Getting the object count
                
        fprintf('  Found %d object(s)\n', count );
        est_obj_count_measure(i) = max(0, 1 - abs(gt - count) / gt );
        pause;
    end
    est_obj_count_accuracy = 100*sum(est_obj_count_measure)/num_files;

    fprintf('\nObject count accuracy: %5.1f%% \n', est_obj_count_accuracy);
end

function object_count = estimate_object_count(I_FG, I_BG, threshold)
    current_count = 0;
    min_area = 200;  % Minimum area of a detected object
    TH = threshold * 255;
    diff = sum(abs(double(I_FG) - double(I_BG)), 3);  % Get the difference between the Foreground and Background
    diff = diff > TH;  % Binarize the difference
    A_diff_closed = imclose(diff, strel('disk', 2));
    REV = ~A_diff_closed;
    object_count = 0;
    [rows, cols] = size(REV);

    subplot(1, 3, 3);
    imshow(REV);
    title("DETECTED POINTS");

    % For each pixel...
    for r = 1:rows
        for c = 1:cols 
            if REV(r, c) == 0  % Check if the pixel is a part of an object
                mask = imfill(REV, [r,c],4);  % If so fill the area and take the difference
                area = sum(REV(:) == 0) - sum(mask(:) == 0);
                
                if area > min_area  % If the area is bigger than the minimum area, 
                   current_count = current_count + 1;  % Increment the object count, get the center and plot the number
                   area_m = abs(REV - mask);
                   [a_rows, a_cols] = find(area_m);
                   a_x = mean(a_cols);
                   a_y = mean(a_rows);
                   text(a_x, a_y, num2str(current_count), 'Color','red','FontSize',20);
                end
                REV = mask;  % Update the reversed to continue searching
            end
        end
    end
    object_count = current_count;  % Return the object count
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
