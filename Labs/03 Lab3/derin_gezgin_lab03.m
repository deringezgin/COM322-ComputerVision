main()

function []=main()
    check1()
end

function []=check1()
    img = rand(200, 600, 3);
    img(1:67, 1:200, :) = 0;
    img(1:67, 400:600, :) = 0;
    img(122:200, 1:200, :) = 0;
    img(122:200, 400:600, :) = 0;
    img(75:115, 210:250, :) = 1;
    img(75:115, 340:380, :) = 1;
    imshow(img)
    pause;
end

function []=check2()
    canvas_a = zeros(200, 600); 
    for i = 1:600
        canvas_a(:, i) = i / 600;
    end
    imshow(canvas_a); 
    pause;

    canvas_b = zeros(200, 600,3); 
    for i = 1:600
        canvas_b(:, i,2) = i / 600;
    end
    imshow(canvas_b); 
    pause;

    canvas_c = zeros(200,600,3);
    for i = 1:600
        canvas_c(:,i,2) = i/600;
        canvas_c(:,601-i,1) = i/600;
    end
    imshow(canvas_c);
    pause;
end

function []=check3()
    original_clock = imread("images/clock.JPG");
    
    horizental_clock = original_clock(:, end:-1:1);
    vertical_clock = original_clock(end:-1:1, :);
    double_flip = original_clock(end:-1:1, end:-1:1);
    combined = [original_clock, horizental_clock; vertical_clock, double_flip];
    imshow(combined)
    pause;
end

function []=check4()
    single_brick = imread("images/bricks.jpg");
    XTILES = 10;
    YTILES = 5;
    [height, width, channels] = size(single_brick);
    empty_canvas = zeros(height * YTILES, width * XTILES, channels, 'uint8');
    for y = 1:YTILES
        for x = 1:XTILES
            start_row = (y-1) * height + 1;
            start_col = (x-1) * width + 1;
            tiledImage(start_row:start_row+height-1, start_col:start_col+width-1, :) = single_brick;
        end
    end
    imshow(tiledImage)
    pause;
end

function []=check5()
    einstein = imread("images/einstein.jpg");
    imshow(einstein)
    pause;
    
    dark_einstein = einstein * 0.5;
    imshow(dark_einstein)
    pause;
    
    bright_einstein = einstein * 1.5;
    imshow(bright_einstein)
    pause;

    dark_einstein = einstein > 128;
    imagesc(dark_einstein)
    pause;

    negative_einstein = 255 - dark_einstein;
    imshow(negative_einstein);
    pause;

    yellow_einstein = einstein;
    yellow_einstein(:, :, 3) = 0;
    imshow(yellow_einstein);
    pause;
end

function []=check6()
    tree_painter = imread("images/tree_painter.jpg");
    [rows, cols, ~] = size(tree_painter);
    
    half_tree = tree_painter;
    for i=1:rows
        for j=1:cols
            if j <= cols/2
                half_tree(i, j, 2) = 0;
            else
                half_tree(i, j, 3) = 0;
            end
        end
    end
    imshow(half_tree);
    pause;

    tree_white = tree_painter;
    tree_canvas = ones(rows, cols);
    
    counter = 0;
    for i=1:rows
        for j=1:cols
            red_val = tree_white(i, j,1);
            green_val = tree_white(i, j,2);
            blue_val = tree_white(i, j,3);
            if red_val < 100 && green_val > 100 && blue_val < 100
                counter = counter + 1;
                tree_white(i,j,:) = 255;
                tree_canvas(i,j,:) = 0;
            end
        end
    end

    percentage = counter / (rows * cols);
    disp(percentage)
    imshow(tree_white);
    pause;

    imshow(tree_canvas);
    pause;
end

function []=check7()
    original_campbells = imread("images/warhol_campbells.jpg");
    edited_campbells = imread("images/warhol_campbells_ed.jpg");
       
    [rows, cols, ~] = size(original_campbells);
    canvas = zeros(rows,cols);

    for i=1:rows
        for j=1:cols
            dist=0;
            for c=1:3
                dist = dist + (double(original_campbells(i,j,c))-double(edited_campbells(i,j,c)))^2;
            end 
            dist = sqrt(dist);
            if dist > 60
                canvas(i,j)=1;
            end
        end 
    end 
    imshow(canvas);
    pause;
end
