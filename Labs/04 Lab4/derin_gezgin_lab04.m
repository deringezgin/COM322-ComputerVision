main()
function []=main()
    check4()
end

function []=check1()
    sign = imread("images/no-overtaking-sign.jpg");
    
    sign_hsv = rgb2hsv(sign);
    threshold = 0.5;
    
    mask = sign_hsv(:, :, 3) < threshold;
    sign(repmat(mask, [1, 1, 3])) = 0; 
    sign(:,:,2) = sign(:,:,2) + uint8(mask) * 100;
    
    imshow(sign);
    pause;
end

function []=check2()
    % Part A
    width = 600; 
    height = 400;
    
    hue = linspace(0, 1, width);
    hsv = zeros(height, width, 3); 
    
    hsv(:,:,2:3) = 1;
    
    img = hsv2rgb(hsv);
    imshow(img);
    pause;

    % Part B
    sat = linspace(0, 1, width);
    hsv = zeros(height, width, 3);
    hsv(:, :, 1) = 0.65;
    hsv(:, :, 2) = repmat(sat, height, 1);
    hsv(:, :, 3) = 1;

    img = hsv2rgb(hsv);
    imshow(img);
    pause;

    % Part C
    bright = linspace(0, 1, width);
    hsv = zeros(height, width, 3);
    hsv(:, :, 1) = 0.65;
    hsv(:, :, 2) = 1;
    hsv(:, :, 3) = repmat(bright, height, 1);
    
    img = hsv2rgb(hsv);
    imshow(img);
    pause;
end

function []=check3()
    original_campbells = imread("images/warhol_campbells.jpg");
    edited_campbells = imread("images/warhol_campbells_ed.jpg");
       
    hsv_original = rgb2hsv(original_campbells);
    hsv_edited = rgb2hsv(edited_campbells);

    [rows, cols, ~] = size(hsv_edited);
    canvas = zeros(rows,cols);

    for i=1:rows
        for j=1:cols
            dist=0;
            for c=1:1
                if c == 1
                    % We have the check this specific case as the hue distance is circular
                    hue_diff = abs(hsv_original(i,j,c) - hsv_edited(i,j,c));
                    hue_diff = min(hue_diff, 1 - hue_diff); 
                    dist = dist + hue_diff^2;
                else
                    dist = dist + (double(hsv_original(i,j,c)) - double(hsv_edited(i,j,c)))^2;
                end
            end 
            dist = sqrt(dist);
            if dist > 0.05  
                canvas(i,j)=1;
            end
        end 
    end 
    imshow(canvas);
    pause;
end

function [] = check4()
    lines = imread("images/fill_between3.jpg");
    hsv_lines = rgb2hsv(lines);

    [rows, cols, ~] = size(lines);
    LOWER = 0.2;
    UPPER = 0.8;
    for i=1:rows
        current_col = 1;
         while current_col <= cols && hsv_lines(i, current_col, 2) < LOWER && hsv_lines(i, current_col, 3) > UPPER
            current_col = current_col + 1;
        end

         while current_col <= cols && ~(hsv_lines(i, current_col, 2) < LOWER && hsv_lines(i, current_col, 3) > UPPER)
            current_col = current_col + 1;
         end

         while current_col <= cols && hsv_lines(i, current_col, 2) < LOWER && hsv_lines(i, current_col, 3) > UPPER
             lines(i, current_col, 1) = 255;
             lines(i, current_col, 2:3) = 0; 
             current_col = current_col + 1;
             if current_col == cols
                while current_col <= cols && hsv_lines(i, current_col, 2) < LOWER && hsv_lines(i, current_col, 3) > UPPER
                    lines(i, current_col, :) = 255;
                    current_col = current_col - 1;
                end
            end
         end
         
    end
    imshow(lines);
    pause;
end

function []=check5_6()
    firetruck = imread("images/fire_truck.jpg");
    imshow(firetruck);
    pause(2);
    firetruck_hsv = rgb2hsv(firetruck);
    green_hsv = rgb2hsv(firetruck);
    blue_hsv = rgb2hsv(firetruck);
    yellow_hsv = rgb2hsv(firetruck);
    [rows, cols, ~] = size(firetruck_hsv);
    canvas = zeros(rows, cols, 3);
    for r=1:rows
        for c=1:cols
            target_pixel = firetruck_hsv(r, c, :);
            if (target_pixel(2) > 0.2) && (target_pixel(1) < 0.1 || target_pixel(1) > 0.9)
                canvas(r, c, :) = 255;
                green_hsv(r, c, 1) = 0.3;
                blue_hsv(r, c, 1) = 0.6;
                yellow_hsv(r,c,1) = 0.16;
                
            end
        end
    end
    imagesc(canvas);
    pause(0.5);
    imshow(hsv2rgb(green_hsv));
    pause(0.5);
    imshow(hsv2rgb(blue_hsv));
    pause(0.5);
    imshow(hsv2rgb(yellow_hsv));
    pause(1);
end
