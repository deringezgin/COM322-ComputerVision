% Derin Gezgin
% COM322: Computer Vision | Fall 2024 | Homework #3
% Due November 6th, 2024
% Problem I: Running only the face detector and obtain an accuracy.

clc;
image_framework();
function image_framework
    IMAGE_FILE_TYPE = 'jpg';
    
    % Getting the file names
    [fg_fn, gt_fn] = get_files(IMAGE_FILE_TYPE);
    num_files = numel(fg_fn);
    
    % Array to keep track of our predictions
    est_face = zeros(num_files, 1);

    for k = 1:num_files
        fprintf('Processing file: %s -- ', fg_fn{k} );

        % Getting the image
        I_FG = imread(fg_fn{k});
        
        figure(1); 
        
        gt_face = get_gt(gt_fn{k});  % Ground-truth
        
        % Checking if there is face or not
        predicted_face = estimate_face(I_FG);

        % Getting the correctness
        correct = (gt_face ~=9 && predicted_face==1)||(gt_face ==9 && predicted_face~=1);
        fprintf('Face found (T/F): %1d   [GT: %1d]  CORRECT: %1d\n', predicted_face, gt_face~=9, correct );
                
        est_face(k) = correct;
    end
    classification_accuracy = 100*sum(est_face)/num_files;

    fprintf('\nScene Classification Accuracy: %5.1f%% \n', classification_accuracy);
end

% Function to check if there is a face in the image
function face_exist = estimate_face(I_FG)
    face = vision.CascadeObjectDetector('MergeThreshold', 7);

    BB = face(I_FG);
    imshow(I_FG);

    if ~isempty(BB)
        for i = 1:size(BB, 1)
            rectangle('Position', BB(i, :), 'LineWidth', 2, 'LineStyle', '-', 'EdgeColor', 'b');
        end
    end

    face_exist = size(BB, 1);
end

% Function to get the files with the specific type
function [fg_fn, gt_fn] = get_files(im_type)
    fg_fn = {};
    gt_fn = {};
    fg_imgs = dir ( strcat( 'images/*frg.', im_type) );
    for i = 1:numel(fg_imgs)
        fg_fn{i} = ['images/' fg_imgs(i).name];
        stem = fg_fn{i}(1:end-7);
        gt_fn{i} = [stem '.txt']; 
    end
end

% Function to get the ground-truth from the .txt file
function content = get_gt(txtfile)
    fileID = fopen(txtfile, 'r');
    content = fscanf(fileID, '%d');
    fclose(fileID);
end
