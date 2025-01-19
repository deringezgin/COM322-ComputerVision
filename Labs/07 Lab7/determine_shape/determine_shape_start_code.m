% Image batch processing framework for evaluation.
%
% Expects jpg images in a subfolder called 'images' with the following naming conventions: 
%   *.jpg for the images (e.g. im001.jpg) (no background images in this version)
%
% Modify this code for your own purpose.
% Authors: Ward & Izmirli

clc;
image_framework();

function image_framework
    IMAGE_FILE_TYPE = 'jpg';
    
    % --- get file names of necessary files in the images subfolder
    [fg_fn, gt_fn] = get_files(IMAGE_FILE_TYPE);
    num_files = numel(fg_fn);
    
    % --- initialize arrays to keep the estimation results 
    est_shape = zeros(num_files, 1);  % 1 correct; 0 not correct
 
    for k = 1:num_files
        fprintf('Processing file: %s -- ', fg_fn{k} );

        % --- get the image
        I_FG = imread(fg_fn{k});
        
        figure(1); 
        imshow(I_FG);
        hold on;
        
        gt_shape = get_gt(gt_fn{k});  % shapes 0,1,2,3; See the gt2txt function below
        
        % ----- placeholder code for estimating the shape (replace with your own estimation code)
        predicted_shape = get_prediction(I_FG);
        % ------ end of placeholder code
        
        correct = (predicted_shape == gt_shape);
        fprintf('Predicted Shape: %1d   [GT: %1d (%s)]  CORRECT: %1d\n', predicted_shape, gt_shape, gt2txt(gt_shape), correct );
                
        est_shape(k) = correct;
        pause;
    end
    classification_accuracy = 100*sum(est_shape)/num_files;

    fprintf('\nShape Recognition Accuracy: %5.1f%% \n', classification_accuracy);
    

end

%----------------------------------------------------------------------------------
% -------------------- ESTIMATION FUNCTIONS ---------------------------------------
% additional estimation functions can go here.

function prediction = get_prediction(I_FG)
    im_bw = rgb2gray(I_FG);
    sigma = 1;
    thresh = 7000;
    radius = 10;
    [~, r, c] = harris(im_bw, sigma, thresh, radius);
    plot(c, r, 'r.', 'markersize', 20); 
    title('Detected Corners');
    hold off; 
    corner_count = length(r)-4;
    if corner_count == 4
        % Check if the shape is a square
        dist1 = sqrt((r(1) - r(2))^2 + (c(1) - c(2))^2);
        dist2 = sqrt((r(2) - r(3))^2 + (c(2) - c(3))^2);
        if abs(dist1 - dist2) < 165
            prediction = 1;
        else
            prediction = 0;
        end
    elseif corner_count == 3
        prediction = 2; 
    else
        prediction = 3;
    end
end

%----------------------------------------------------------------------------------
% -------------------- HELPER FUNCTIONS -------------------------------------------

%----------------------------------------------------------------------------------
% Reads all the relevant file names from the subfolder called 'images'
% fg_fn contains foreground image file info; e.g. access as fg_fn{1}
% gt_fn contains ground truth data file names
function [fg_fn, gt_fn] = get_files(im_type)
    fg_fn = {};
    gt_fn = {};
    fg_imgs = dir ( strcat( 'images/*.', im_type) );
    for i = 1:numel(fg_imgs)
        fg_fn{i} = ['images/' fg_imgs(i).name];
        stem = fg_fn{i}(1:end-4);  % trim 'frg.jpg'
        gt_fn{i} = [stem '.txt']; 
    end
end

%----------------------------------------------------------------------------------
% Gets the GT data. 'txtfile' is a string containing name of the txt file containing ground truth
function content = get_gt(txtfile)
    fileID = fopen(txtfile, 'r');
    content = fscanf(fileID, '%d');
    fclose(fileID);
end

%----------------------------------------------------------------------------------
% Maps the numerical ground truth to its associated string
function str = gt2txt(gt_num)
    switch gt_num        
        case 0
            str = 'RECTANGLE';
         case 1
            str = 'SQUARE';
         case 2
            str = 'TRIANGLE';
         case 3
            str = 'STAR';            
    end
end