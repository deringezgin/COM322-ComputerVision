main();

function []=main()
    check4()
end

function []=check1()
    signal_length = 1200;
    filter_length = 50;
    filter = zeros(filter_length,1);
    
    filter(:) =  1/filter_length;
    signal = zeros(1, signal_length);
    signal(75:85) = 1;
    signal(200:225) = 1;
    signal(280:320) = 1;
    signal(500:600) = 1;
    % Plot original signal
    plot(signal, 'g') % Plot in green
    hold on;
    
    % Initialize the filtered signal array
    filtered_signal = zeros(1, signal_length);
    
    for i=1:signal_length-filter_length-1
        sum = 0;
        for j =1:filter_length
            sum = sum + (signal(i+j)*filter(j));
        end
        filtered_signal(i) = sum;
    end
    plot(filtered_signal, 'r');
    hold off;
end

function []=check2()
    img = imread("images/Zebra_Botswana.jpg");
    img2 = imread("images/switzerland.jpg");
    N = 29;
    kernel = (1/(N*N)) * ones(N);
    [cols, rows, channels] = size(img);
    half_kernel = floor(N/2);
    new_img = zeros(cols, rows, 3);
    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            for c=1:channels
                roi = double(img(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j,c) = sum_num;
            end
        end
    end
    new_img = uint8(new_img);
    figure(1);
    imshow(img);
    figure(2);
    imshow(new_img);

    N = 31;
    kernel = (1/(N*N)) * ones(N);
    [cols, rows, channels] = size(img2);
    half_kernel = floor(N/2);
    new_img = zeros(cols, rows, 3);
    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            for c=1:channels
                roi = double(img2(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j,c) = sum_num;
            end
        end
    end
    new_img = uint8(new_img);
    figure(3);
    imshow(img2);
    figure(4);
    imshow(new_img);
    pause; 
end

function []=check3()
    img = imread("images/fruit_blurred_5x5.jpg");
    img2 = imread("images/Zebra_Botswana_blurred_11x11.jpg");
    kernel = [-1, -1, -1; -1, 9, -1; -1, -1, -1];
    [cols, rows, channels] = size(img);
    half_kernel = floor(size(kernel,1)/2);
    new_img = zeros(cols, rows, 3);
    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            for c=1:channels
                roi = double(img(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j,c) = sum_num;
            end
        end
    end
    new_img = uint8(new_img);
    figure(1);
    imshow(img);
    figure(2);
    imshow(new_img);
    
    kernel = [-1, -1, -1; -1, 9, -1; -1, -1, -1];
    [cols, rows, channels] = size(img2);
    half_kernel = floor(size(kernel,1)/2);
    new_img = zeros(cols, rows, 3);
    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            for c=1:channels
                roi = double(img2(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j,c) = sum_num;
            end
        end
    end
    
    new_img = uint8(new_img);
    figure(3);
    imshow(img2);
    figure(4);
    imshow(new_img);
    pause;

end

function []=check4()
    img = imread("images/switzerland.jpg");
    [cols, rows, ~] = size(img);
    kernel = [1,2,1;0, 0, 0; -1, -2, -1];
    canvas = zeros(cols, rows);
    canvas(:, :) = img(:, :, 1) * 0.299 + img(:, :, 2) * 0.587 + img(:, :, 3) * 0.114;

    half_kernel = floor(size(kernel,1)/2);
    new_canvas = uint8(zeros(cols, rows));

    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            roi = double(canvas(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel));
            sum_num = sum(kernel .* roi, "all");
            new_canvas(i, j) = sum_num;
        end
    end

    figure(1);
    imshow(new_canvas);

    kernel = kernel';
    new_canvas = uint8(zeros(cols, rows));

    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            roi = double(canvas(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel));
            sum_num = sum(kernel .* roi, "all");
            new_canvas(i, j) = sum_num;
        end
    end

    figure(2);
    imshow(new_canvas);
    pause;

end

function []=check5()
    img = imread("images/noisy_man.png");
    N = 7;
    kernel = (1/(N*N)) * ones(N);
    [cols, rows, channels] = size(img);
    half_kernel = floor(N/2);
    new_img = zeros(cols, rows, 3);
    for i=1+half_kernel:cols-half_kernel
        for j=1+half_kernel:rows-half_kernel
            for c=1:channels
                roi = double(img(i-half_kernel:i+half_kernel, j-half_kernel:j+half_kernel, c));
                sum_num = sum(kernel .* roi, "all");
                new_img(i, j,c) = sum_num;
            end
        end
    end
    new_img = uint8(new_img);
    figure(1);
    imshow(img);
    figure(2);
    imshow(new_img);

    kernel = ones(N);
    new_img = zeros(cols, rows, 3);
    for c=1:channels
        new_img(:,:,c) = medfilt2(img(:,:,c), [N N]);
    end
    new_img = uint8(new_img);
    figure(3);
    imshow(new_img);
end