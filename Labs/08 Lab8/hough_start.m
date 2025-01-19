% Start code for 
function hough_start
fn{1} = 'line_1.jpg';  % one line
fn{2} = 'line_2.jpg';  % one line
fn{3} = 'line_3.jpg';  % one line
fn{4} = 'line_4.jpg';  % one line
fn{5} = 'line_5.jpg';  % two lines
fn{6} = 'line_6.jpg';  % three lines
fn{7} = 'line_7.jpg';  % four lines
fn{8} = 'line_8.jpg';  % curve + line - only detect line
fn{9} = 'line_9.jpg';  % curve only - should not detect anything


for i = 1 : length(fn)
    image1 = imread( fn{i} );
    figure(1);
    imshow(image1);
    
    % --- Perform Canny Edge Detection
  
    % --- Initialize accumulator matrix A
    
    % --- Fill A using the egde image
    
    % --- Draw a line on either the original or the edge image
    
    % --- Observe accuracy of line detection visually for each image
    
    pause;
end
