% 1. Write a code that produces several figures

% 1.A
fig = zeros(35, 35);
for n=1:length(fig)
    fig(n,n) = 1;
end
imagesc(fig)
pause;

% 1.B
fig = zeros(35, 35);
for n=1:length(fig)
    fig(n, length(fig)-n+1) = 1;
end
imagesc(fig)
pause;

% 1.C
fig = zeros(35,35);
for n=1:length(fig)
    fig(n,n) = 1;
    fig(n, length(fig)-n+1) = 1;
end
imagesc(fig)
pause

% 1.D
fig = zeros(35, 35);
fig(1, :) = 1;                        
fig(length(fig), :) = 1;
fig(:, 1) = 1;
fig(:, length(fig)) = 1;
for n=1:length(fig)
    fig(n,n) = 1;
    fig(n, length(fig)-n+1) = 1;
end
imagesc(fig)
pause;

% 1.E
fig = zeros(35,35);
for n=1:length(fig)
    for a =1:floor(35/5)-1
        if n + 5 * a <= length(fig)
            fig(n,n + 5 * a) = 1;
        end
    end
end
imagesc(fig) 
pause


% 1.F
fig = zeros(35, 35);
for r=1:length(fig)
    for c=1:length(fig)
        if c<=r && mod(r+c,2) ==0
            fig(r,c) =1;
        end
    end
end
imagesc(fig)
pause;

% 2. the "divN" function
function result = divN(r, c, N)
    check_val = r^4 + c;
    if mod(check_val, N) == 0
        result = 1;
    else
        result = 0;
    end
end

function matrix = main(matrix, N)
    for r = 1:length(matrix)
        for c = 1:length(matrix)
            matrix(r,c) = divN(r, c, N);
        end
    end
end

new_matrix_3 = main(zeros(30,30), 3);
imagesc(new_matrix_3)
pause;

new_matrix_4 = main(zeros(30,30), 4);
imagesc(new_matrix_4)
pause;

new_matrix_7 = main(zeros(30,30), 7);
imagesc(new_matrix_7)
pause;

% 3. Square-Matrix Function
function A = square(A, r, c, size, intensity)
    if (r + size - 1 > length(A) || c + size - 1 > length(A))
        return;
    end
    A(r:r+size-1, c:c+size-1)=intensity;
end

function main2()
    A = zeros(100, 100);
    for i=1:7
        r = randi(100);
        c = randi(100);
        max_size = min(100 - r + 1, 100 - c + 1);
        size = randi(max_size);
        intensity = randi(255);
        A = square(A, r, c, size, intensity);
    end
    imagesc(A)
    pause;
end

main2()

% 4. Random Image Analysis

random_image = randi([0,1], 40, 40);

new_image = zeros(40,40);
for r = 2:length(random_image)-1
    for c = 2:length(random_image)-1
        block = random_image(r-1:r+1, c-1:c+1);
        if block(2,2) == 1
            % Calculate the sum of the block
            if sum(block(:)) == 1
                new_image(r,c) = 1;
            end
        end
    end
end
figure;
figure(1);
imagesc(random_image);
figure(2);
imagesc(new_image);
pause;