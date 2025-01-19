% Derin Gezgin
% COM322: Computer Vision | Fall 2024 | Homework #3
% Due November 6th, 2024
% Problem III: Enhancing the face detection by detecting eyes, mouth, nose

clc;
image_framework();
function image_framework
    IMAGE_FILE_TYPE = 'jpg';
    
    % Getting the file names
    [fg_fn, gt_fn] = get_files(IMAGE_FILE_TYPE);
    num_files = numel(fg_fn);
    
    % Array to keep track of our predictions
    est_face = zeros(num_files, 1);  % 1 correct; 0 not correct
 
    for k = 1:num_files
        fprintf('Processing file: %s -- ', fg_fn{k} );

        % Getting the image
        I_FG = imread(fg_fn{k});
        
        gt_face = get_gt(gt_fn{k});  % Ground-truth
        
        % Checking if there is face or not
        predicted_face = check_face(I_FG, 0.15);
        
        % Getting the correctness
        correct = (gt_face ~=9 && predicted_face==1)||(gt_face ==9 && predicted_face~=1);
        fprintf('Face found (T/F): %1d   [GT: %1d]  CORRECT: %1d\n', predicted_face, gt_face~=9, correct );
                
        est_face(k) = correct;
    end
    classification_accuracy = 100*sum(est_face)/num_files;

    fprintf('\nScene Classification Accuracy: %5.1f%% \n', classification_accuracy);
end

function component_exist = estimate_component(I_FG, component, threshold)
    detect_component = vision.CascadeObjectDetector(component, 'MergeThreshold', threshold);
    angles = [0, 30, -30];
    BB = [];
    
    for angle = angles
        rotated_I_FG = imrotate(I_FG, angle);
        BB = detect_component(rotated_I_FG);
        if ~isempty(BB)
            break;
        end
    end

    if size(BB,1) > 0
        component_exist = 1;
    else
        component_exist = 0;
    end
end

% Function to check for a face in the image by looking for specific attributes of a face like L/R eye, nose, mouth
% Each attribute has their own weight and the final prediction also has a threshold
function face_exist  = check_face(I_FG, threshold)
    components = {'Mouth'; 'Nose'; 'LeftEye'; 'RightEye'};
    component_weights = [0.3; 0.3; 0.2; 0.2];

    final_prediction = 0;
    for i = 1:length(component_weights)
        component_name = components{i};
        component_weight = component_weights(i);
        component_exist = estimate_component(I_FG, component_name, 5);
        weighted_component = component_exist * component_weight;
        final_prediction = final_prediction + weighted_component;
    end

    if final_prediction > threshold
        face_exist = 1;
    else
        face_exist = 0;
    end
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
