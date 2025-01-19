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

end

normal_templates = get_templates(D_all, 1923);
get_best_match(T_all, normal_templates);

mean_templates = get_mean_template(D_all);
get_best_match(T_all, mean_templates);

hog_templates = get_HOG_templates(D_all, 1923);
get_HOG_match(T_all, hog_templates);

mean_hog_templates = get_mean_HOG_templates(D_all);
get_HOG_match(T_all, mean_hog_templates);

function accuracy = get_best_match(T_all, templates)
    correct_count = 0;
    total_count = 0;

    for number = 1:10  % Iterate over each digit
        test_images = T_all{number};  % Test images for the current digit

        for n = 1:size(test_images, 1)  % Iterate over each test image
            test_image = squeeze(test_images(n, :, :));
            max_correlation = 0;
            best_match = -1;

            for template_number = 1:10  % Iterate over each template
                template = templates{template_number};
                correlation = corrcoef(template(:), test_image(:));
                correlation_val = correlation(1,2);

                if correlation_val > max_correlation
                    max_correlation = correlation_val;
                    best_match = template_number;
                end
            end

            if best_match == number
                correct_count = correct_count + 1;
            end
            total_count = total_count + 1;
        end
    end

    % Calculate and display accuracy
    accuracy = (correct_count / total_count) * 100;
    fprintf('Max Correlation Accuracy for the Best Match: %.2f%%\n', accuracy);
end

function accuracy = get_HOG_match(T_all, templates)
    cellSize = [4,4];
    correct_count = 0;
    total_count = 0;

    for number = 1:10  % Iterate over each digit
        test_images = T_all{number};  % Test images for the current digit

        for n = 1:size(test_images, 1)  % Iterate over each test image
            test_image = squeeze(test_images(n, :, :));
            hog_values = extractHOGFeatures(test_image, 'CellSize', cellSize);
            max_correlation = 0;
            best_match = -1;

            for template_number = 1:10  % Iterate over each template
                template = templates{template_number};
                correlation = corrcoef(template(:), hog_values(:));
                correlation_val = correlation(1,2);

                if correlation_val > max_correlation
                    max_correlation = correlation_val;
                    best_match = template_number;
                end
            end

            if best_match == number
                correct_count = correct_count + 1;
            end
            total_count = total_count + 1;
        end
    end

    % Calculate and display accuracy
    accuracy = (correct_count / total_count) * 100;
    fprintf('Max Correlation Accuracy for the Best Match: %.2f%%\n', accuracy);
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
     
