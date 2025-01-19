% 1.A Display elements of the matrix A
A = [3 6 1 9; 6 5 3 7; 7 3 2 6]; 
disp("Different elements of A")
disp(A(1, 2))
disp(A(3, 2))
disp(A(2, 3))

% 1.B: First row of the matrix
disp("First row of the matrix")
disp(A(1, :))

% 1.C" Second column of the matrix
disp("Second column of the matrix")
disp(A(:, 2))

% 1.D: Sub-matrix consisting of rows 2 & 3 and columns 3 & 4
disp("Sub-matrix with specific row/columns")
disp(A(2:3, 3:4))

% 2.A Multiplication of a matrix with a scalar
B = [5 7; 2 9];
disp("Multiplication of a matrix with a scalar")
disp(B * 4.5)

% 2.B Matrix addition
C = [2 6 4; 9 7 2; 3 4 8];
D = [3 7 4; 12 3 5; 1 11 4];
disp("Matrix addition")
disp(C + D)

% 2.C Element-wise vector multiplication
E = [4; 6; 2; 1; 8];
F = [3; 7; 4; 5; 9];
disp("Element-wise multiplication")
disp(E .* F)

% 2.D Matrix Multiplication
G = [2 6 1 3];
H = [3 8 2 5];
disp("Matrix Multiplication")
disp(G .* H')

% 2.E Matrix Multiplication p.2
disp("Matrix Multiplication p.2")
disp(H' .* G)

% 3 Construct an array containing zeros and assign elements
I = zeros(5, 10);
I(3, 5) = 44;
I(2, 4) = 44;
I(1, 9) = 44;
disp("Array of 0s containing 44")
disp(I)

% 4.A Assign variable c a value of 200. Cast to type uint8, display the result
c = uint8(200);
disp("c (200) as uint8, and int8")
disp(c)

% 4.B Assign variable c a value of 200. Cast to type iny8, display the result
c = int8(200);
disp(c)

% Repeating parts for the -150
disp("c (-150) as uint8, and int8")
c = uint8(-150);
disp(c)
c = int8(-150);
disp(c)

% 5.A Create a column vector called vect1 that contains even numbers in the range 100-200
vect1 = 100: 2: 120;
disp("vect1 containing even numbers")
disp(vect1)

% 5.B Create a row vector called vect2 that contains number in the range 0 to 1 in increments of 0.1
vect2 = (0: 0.1: 1)';
disp("vect2 that contains numbers from 0 to 1 with 0.1 increments")
disp(vect2)

% 5.C Multiply vect2 by 100, assign that result back to vect2 and display the result
vect2 = vect2 * 100;
disp("Multiply vect2 by 100")
disp(vect2)

% 5.D Display the lengths of both vectors and make sure they are equal.
disp("Lengths of both vectors")
disp(length(vect1))
disp(length(vect2))
% Display the element-wise sum
vect3 = vect1' + vect2;
disp("Element-wise sum")
disp(vect3)

% 6. Sum of integers divisible by 7 between 161 and 224
disp("Sum of integers divisible by 7 between 161 - 224")
disp(sum(161: 7: 224))

% 7.A Assign variable d a value of 5 and check if it's in the range
d = 5;
test = (d>=1 && d<=3) || (d>=6 && d<=9);
disp("Test with 5")
disp(test)

d = 2;
test = (d>=1 && d<=3) || (d>=6 && d<=9);
disp("Test with 2")
disp(test)

% 7.B Assign variable d a vector that contains 20 random integers in the range 1 to 10.
J = randi(10, 20, 1);
K = randi(10, 20, 1);

disp("Checking the equal count.")
disp(sum(J == K))

% 8.A Create a sequence of 21 numbers that increase linearly from 0 to 10
% followed by a decrease. 

asc = (0:0.5:10);
desc = (10:-0.5:0);
comb = [asc desc];
display(comb)
plot(comb)  % Normal one
pause;
plot(comb, "b+")  % Blue + markers
pause;

% 8.B Creating a square wave
z = zeros(1, 50);
o = ones(1, 50);
comb = [o z o z o z o z];
axis( [0, Inf, -.3, 1.3] )
plot(comb)
pause;

% 9 Working on A and displaying it
A = [1 0; 0 1];
imagesc(A)
pause;

A = [3 5 2; 8 6 1];
imagesc(A)
pause;

A = [0:0.01:1; 1:-0.01:0];
imagesc(A)
pause;

% 10.A Create vector B and assign values
B = zeros(15, 1);
B([1 3 6 7]) = 1;
B(5:7) = 1;
disp(B)

% 10.B Create a 25x25 / 40x40 / 50x50 matrix and fill it with a check-board pattern using 0 and 1s
M = zeros(25, 25);
M(1:2:end, 1:2:end) = 1;
M(2:2:end, 2:2:end) = 1;
imagesc(M)
pause;

M = zeros(40, 40);
M(1:2:end, 1:2:end) = 1;
M(2:2:end, 2:2:end) = 1;
imagesc(M)
pause;

M = zeros(50, 50);
M(1:2:end, 1:2:end) = 1;
M(2:2:end, 2:2:end) = 1;
imagesc(M)
pause;
