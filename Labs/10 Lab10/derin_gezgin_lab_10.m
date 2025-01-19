% Framework for reading digits
% THE MNIST DATABASE of handwritten digits
% Images are 28x28 grayscale of type double with values 0 - 255
% Derin Gezgin Lab-10

clc;
for d = 0:9
    % get training data
    load(['mnist/digit' num2str(d) '.mat']);
    D_all{d+1} = permute( reshape(D, size(D,1), 28,28) , [1,3,2]);
    
    % get test data
    load(['mnist/test' num2str(d) '.mat']);
    T_all{d+1} = permute( reshape(D, size(D,1), 28,28) , [1,3,2]);
    c = size(D_all{d+1});
    fprintf('Handwritten Digit Dataset has %d samples for digit %d\n', c(1), d );
end

normal_templates = get_templates(D_all, 1923);
for i = 1:10
    get_best_match(T_all, normal_templates{i});
end

mean_templates = get_mean_template(D_all);
for i = 1:10
    get_best_match(T_all, mean_templates{i});
end

hog_templates = get_HOG_templates(D_all, 1923);
for i = 1:10
    get_best_hog_match(T_all, hog_templates{i});
end

mean_hog_templates = get_mean_HOG_templates(D_all);
for i = 1:10
    get_best_hog_match(T_all, mean_hog_templates{i});
end

function templates = get_templates(D_all, template_num)
    for i = 0:9
        template = D_all{i+1}(template_num, :, :);
        templates{i+1} = squeeze(template);
    end
end

function mean_templates = get_mean_template(D_all)
    for i = 0:9
        nums = D_all{i+1};
        mean_template = mean(nums, 1);
        mean_templates{i+1} = squeeze(mean_template);
    end
end

function mean_hog_templates = get_mean_HOG_templates(D_all)
    cellSize = [4 4];
    for i = 0:9
        nums = D_all{i+1};
        num_images = size(nums, 1);
        hog_features = zeros(num_images, length(extractHOGFeatures(squeeze(nums(1, :, :)), 'CellSize', cellSize)));
        for n = 1:num_images
            img = squeeze(nums(n, :, :));
            hog_values = extractHOGFeatures(img, 'CellSize', cellSize);
            hog_features(n, :) = hog_values;
        end
        mean_hog_values = mean(hog_features, 1);
        mean_hog_templates{i+1} = mean_hog_values;
    end
end

function hog_templates = get_HOG_templates(D_all, template_num)
    cellSize = [4 4];
    for i = 0:9
        nums = D_all{i+1};
        hog_features = [];

        img = squeeze(nums(template_num, :, :));
        hog_values = extractHOGFeatures(img, 'CellSize', cellSize);
        hog_templates{i+1} = hog_values;
    end
end

function get_best_hog_match(T_all, template)
    cellSize = [4 4];
    max_correlation_number = 0;
    max_correlation_image = 0;
    for i =0:9
        nums = T_all{i+1};
        for n = 1:length(nums)
            test_number = squeeze(nums(n, :, :));
            hog_values = extractHOGFeatures(test_number, 'CellSize', cellSize);
            correlation = corrcoef(template,hog_values);
            correlation_val = correlation(1,2);
            if correlation_val > max_correlation_number
                max_correlation_number = correlation_val;
                max_correlation_image = test_number;
            end
        end
    end
    imshow(max_correlation_image); 
    fprintf('Max Correlation Accuracy for the Best HOG Match: %.2f%%\n', max_correlation_number * 100);
    pause;
end
     
function get_best_match(T_all, template)
    max_correlation_number = 0;
    max_correlation_image = 0;
    for i =0:9
        nums = T_all{i+1};
        for n = 1:length(nums)
            test_number = squeeze(nums(n, :, :));
            correlation = corrcoef(template(:),test_number(:));
            correlation_val = correlation(1,2);
            if correlation_val > max_correlation_number
                max_correlation_number = correlation_val;
                max_correlation_image = test_number;
            end
        end
    end  
    imshow(max_correlation_image);
    fprintf('Max Correlation Accuracy for the Best Match: %.2f%%\n', max_correlation_number * 100);
    pause;
end
