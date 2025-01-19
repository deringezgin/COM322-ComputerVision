% Video batch processing framework for evaluation with optical flow.
%
% Expects mp4 videos in a subfolder called 'videos' 
%
% Modify this code for your own purpose.
%
% Authors: Ward & Izmirli

%function video_framework_optical_flow
    videos = dir('videos\*.mp4');

    % --- initialize arrays to keep the estimation results 
    est_movement = zeros(numel(videos), 1);  % 1 correct; 0 not correct
    est_direction = zeros(numel(videos), 1);  % 1 correct; 0 not correct
    
    % Create a System object to estimate direction
    %optical = opticalFlow; %('OutputValue', 'Horizontal and vertical components in complex form');
    %opticalFlow = vision.opticalFlow('ReferenceFrameDelay', 1);

    th_movement = 0.001;
    for v = 1:numel(videos)
        file = videos(v);
        filename = strcat('videos\', file.name);

        vid_object = VideoReader(filename);
        fprintf('Processing file: %s --  ', filename );
        
        gt = get_gt(filename);

        vid = VideoReader(filename);
        opticFlow = opticalFlowHS;

        figure(1);
        currAxes = axes;
        axis off;
        directionx = [];
        directiony = [];
        while hasFrame(vid)
            frame = readFrame(vid);

            image(frame,"Parent",currAxes)
            currAxes.Visible = "off";
    
            flow = estimateFlow(opticFlow,rgb2gray(frame));

            imshow(frame)
            hold on
            plot(flow, 'color', 'w', 'DecimationFactor',[5 5],'ScaleFactor',25)
            hold off
            pause(1/vid.FrameRate)

            directionx = [directionx, mean(mean(flow.Vx))]; 
            directiony = [directiony, mean(mean(flow.Vy))];
            %fprintf('X vel:%5.3f  Y vel:%5.3f\n', 1000*mean(directionx), 1000*mean(directiony));
            %pause
        end

        vx = mean(directionx);
        vy = mean(directiony);
        figure(2);
        quiver( 0, 0, vx, vy, 'linewidth', 3, 'MaxHeadSize', 0.5);
        sc = 0.005;
        axis([ -sc sc -sc sc]);

        clear vid;
        
        vel = sqrt(vx^2+vy^2);
        est_movement(v) = (vel > th_movement) == gt(1);
        if vel > th_movement
           est_direction(v) = est_movement(v) && (sign(vx) == gt(2));
           fprintf('motion detected: %d  [GT:%d]  (average velocity: %6.4f)     direction [left(-1)/right(1)]: %d [GT: %d]\n',...
               vel > th_movement, gt(1), vel, sign(vx), gt(2));
        else
           est_direction(v) = (gt(1) == 0); % if ground truth is 'no movement' then direction is correct 
        end
        %pause
    end

    fprintf('Movement detection accuracy: %d%% \n',(sum(est_movement)/numel(videos))*100);
    fprintf('Direction estimation accuracy: %d%% \n',(sum(est_direction)/numel(videos))*100);
%end


%----------------------------------------------------------------------------------
% Gets the GT data. 'vid_file_name' is the name of the video file
function content = get_gt(vid_file_name)
    fileID = fopen(strcat(vid_file_name(1:end-4),'.txt'), 'r');
    content = fscanf(fileID, '%d');
    fclose(fileID);
end