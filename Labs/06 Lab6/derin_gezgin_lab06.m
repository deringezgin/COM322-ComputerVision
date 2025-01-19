main();

function []=main()
    check2()
end

function []=check1()
    scrabble = imread("images/scrabble.jpg");
    bw_scrabble = rgb2gray(scrabble);
    roi_s = bw_scrabble(375:432 , 770:830);
    roi_n = bw_scrabble(137:192 , 580:640 );
    roi = roi_n;
    threshold = 0.7;
    c = normxcorr2(roi, bw_scrabble);
    figure;
    imshow(bw_scrabble);
    hold on;
    while true
        if max(c(:)) < threshold
            break;
        end
        [ypeak,xpeak] = find(c==max(c(:)));
        plot(xpeak - (size(roi, 2)/2) + 1, ypeak - (size(roi, 1)/2) + 1, 'g.', 'MarkerSize', 35);
        c(ypeak, xpeak) = 0;
    end
    hold off;
end

function []=check2()
    img1 = rgb2gray(imread("images/mario_image1.jpg"));
    img2 = rgb2gray(imread("images/mario_image2.jpg"));
    roi_default = rgb2gray(imread("images/Mario_Sprite.jpg"));
    img = img2;
    threshold = 0.7;
    figure;
    imshow(img);
    hold on;
    angles = [0, 90, 180, 270];
    for angle = angles
        roi = imrotate(roi_default, angle);
        c = normxcorr2(roi, img);
        while true
            if max(c(:)) < threshold
                break;
            end
            [ypeak,xpeak] = find(c==max(c(:)));
            plot(xpeak - (size(roi, 2)/2) + 1, ypeak - (size(roi, 1)/2) + 1, 'g.', 'MarkerSize', 35);
            c(ypeak, xpeak) = 0;
        end
    end
    hold off;
end