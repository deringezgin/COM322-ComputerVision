% Derin Gezgin
% COM322 - In-Class Assignment - Updated Version

clc;
game_table = imread('table_color_fives.png');

template_5 = game_table(424:508, 287:371,:);
blue_template = template_5;
blur_kernel = (1/(5*5)) * ones(5);
yellow_template = template_5;
blurred_template = apply_kernel(template_5, blur_kernel);
hsv_template = rgb2hsv(template_5);
mask = hsv_template(:, :, 3) > 0.5;

[row,col,cha] = size(template_5);
for r = 1:row
    for c = 1:col
        if mask(r,c) == 1
                blue_template(r,c,1) = 137;
                yellow_template(r, c, 1) = 255;
                blue_template(r,c,2) = 207;
                yellow_template(r, c, 2) = 255;
                blue_template(r,c,3) = 240;
                yellow_template(r, c, 3) = 0;
         end
    end
end

[xlocs, ylocs] = template_matcher_single(game_table, template_5);
blue_img = replace_roi(xlocs, ylocs, blue_template, game_table);
figure(1);
imshow(blue_img);
pause;

[xlocs, ylocs] = template_matcher_multiple(game_table, template_5, 0.9);
yellow_img = replace_roi(xlocs, ylocs, yellow_template, game_table);
figure(2);
imshow(yellow_img);
pause;

blurred_img = replace_roi(xlocs, ylocs, blurred_template, game_table);
figure(3);
imshow(blurred_img);
pause;

image_4_replaced = replace_roi(xlocs, ylocs, get_template(4), game_table);
figure(4);
imshow(image_4_replaced);
pause;
six_dice_image = imread("table_six_dice.png");
figure(5);
imshow(six_dice_image);
hold on;

for num = 1:6
    disp_number_single(six_dice_image, num);
end

pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%

table_3 = imread("table_rand_dice_3.png");
table_5 = imread("table_rand_dice_5.png");
table_6 = imread("table_rand_dice_6.png");

thresholds = 0.95 * ones(1, 6);
process_image(table_3, thresholds, 6);

thresholds = 0.95 * ones(1, 6);
process_image(table_5, thresholds, 6);

thresholds = [0.95, 0.98, 0.95, 0.95, 0.95, 0.98];
process_image(table_6, thresholds, 6);

%%%%%%%%%%%%%%%%%%%%%%%%%%

noisy_1 = imread("table_rand_dice_noisy_1.png");
noisy_2 = imread("table_rand_dice_noisy_2.png");
noisy_3 = imread("table_rand_dice_noisy_3.png");
noisy_4 = imread("table_rand_dice_noisy_4.png");

thresholds = 0.94 * ones(1, 6);
process_image(noisy_1, thresholds, 8);

thresholds = 0.9 * ones(1, 6);
process_image(noisy_2, thresholds, 8);

thresholds = 0.85 * ones(1, 6);
process_image(noisy_3, thresholds, 8);

thresholds = [0.79, 0.8, 0.8, 0.8, 0.8, 0.8];
process_image(noisy_4, thresholds, 8);

%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function process_image(image, thresholds, fig_num)
    updatedImg = image;
    counts = zeros(1, 6);
    xlocs = cell(1, 6);
    ylocs = cell(1, 6);

    for i = 1:6
        if i == 6
            [xlocs{i}, ylocs{i}, ~] = template_matcher_black(updatedImg, get_template(i), thresholds(i));
        else
            [xlocs{i}, ylocs{i}, updatedImg] = template_matcher_black(updatedImg, get_template(i), thresholds(i));
        end
        counts(i) = size(xlocs{i}, 2) * i;
    end

    total = sum(counts);

    figure(fig_num);
    imshow(image);
    hold on;
    for i = 1:6
        write_num(xlocs{i}, ylocs{i}, i);
    end
    text(400, 850, ["Total", num2str(total)], 'Color', 'white', 'FontSize', 20);
    hold off;
    pause;
end

function disp_number_single(img, num)
    template = get_template(num);
    [xloc, yloc] = template_matcher_single(img, template);
    if isempty(xloc) == 0
        write_num(xloc, yloc, num);
    end
end

function [xlocs, ylocs, updatedimg]=template_matcher_black(img, template, threshold)
    xlocs=[];
    ylocs=[];
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    template = rgb2gray(template);
    angles = [0, 90, 180, 270];
    template_default = template;

    for angle = angles
        template = imrotate(template_default, angle);
        c = normxcorr2(template, img);
        while max(c(:)) > threshold
            [ypeak,xpeak] = find(c==max(c(:)));

            xloc = xpeak - (size(template, 2) / 2) + 1;
            yloc = ypeak - (size(template, 1) / 2) + 1;

            xlocs = [xlocs, xloc];
            ylocs = [ylocs, yloc];

            c(ypeak:ypeak, xpeak:xpeak) = 0;
            img(yloc-40:yloc+40, xloc-40:xloc+40, :) = 0;
        end
    end
    updatedimg = img;
end

function A = get_template(i) 
    A = imread(['d_', num2str(i), '.png']);
end

function write_num(xlocs, ylocs, num)
    if length(xlocs) ~= length(ylocs)
        error('xlocs and ylocs must be of the same length');
    end

    for i = 1:length(xlocs)
        text(xlocs(i)-8, ylocs(i)+65, num2str(num), 'Color','white','FontSize',20);
    end
end

function [xlocs, ylocs]=template_matcher_single(img, template)
    img = rgb2gray(img);
    template = rgb2gray(template);
    xlocs=[];
    ylocs=[];
    c = normxcorr2(template, img);

    [ypeak,xpeak] = find(c==max(c(:)));

    xloc = xpeak - (size(template, 2) / 2) + 1;
    yloc = ypeak - (size(template, 1) / 2) + 1;

    xlocs = [xlocs, xloc];
    ylocs = [ylocs, yloc];
end

function new_img = apply_kernel(img, kernel)
    N = size(kernel, 1);
    half_kernel = floor(N/2);

    [cols, rows, channels] = size(img);
    new_img = uint8(zeros(cols, rows, 3));

    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            if channels > 1
                for c=1:channels
                    roi = double(img(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                    sum_num = sum(kernel .* roi, "all");
                    new_img(i, j,c) = sum_num;
                end
            else
                roi = double(img(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, :));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j, :) = sum_num;
            end
        end
    end
end

function new_img=replace_roi(xlocs, ylocs, roi, img)
    if length(xlocs) ~= length(ylocs)
        error('xlocs and ylocs must be of the same length');
    end

    roi_height = size(roi, 1);
    roi_width = size(roi, 2);

    for i = 1:length(xlocs)
        xpeak = xlocs(i) + (roi_width + 1)/2;
        ypeak = ylocs(i) + (roi_height + 1)/2;
        x_start = max(1, xpeak - roi_width + 1);
        y_start = max(1, ypeak - roi_height + 1);
        img(y_start:ypeak, x_start:xpeak, :) = roi;
    end

    new_img = img; 
end

function [xlocs, ylocs]=template_matcher_multiple(img, template, threshold)
    xlocs=[];
    ylocs=[];
    img = rgb2gray(img);
    template = rgb2gray(template);
    angles = [0, 90, 180, 270];
    template_default = template;

    for angle = angles
        template = imrotate(template_default, angle);
        c = normxcorr2(template, img);
        while max(c(:)) > threshold
            [ypeak,xpeak] = find(c==max(c(:)));

            xloc = xpeak - (size(template, 2) / 2) + 1;
            yloc = ypeak - (size(template, 1) / 2) + 1;

            xlocs = [xlocs, xloc];
            ylocs = [ylocs, yloc];

            c(ypeak:ypeak, xpeak:xpeak) = 0;
        end
    end
end
