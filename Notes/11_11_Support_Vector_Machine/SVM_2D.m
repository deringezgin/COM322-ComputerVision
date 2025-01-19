% Demonstrates data creation, SVM classification, and prediction with new data
% using the fitsvm function and the Classification Learner (CL) App. 

%% Prepare some test Data
% Run this cell by pressing <cntr> + <enter> while the cursor is in the cell

num_samples = 1500; % number of samples for each class
space_limit = 10;   % data space limit

class = 1;
mu1 = [-3, -2];    % means
sigma1 = [3, 1.5]; % standard deviations
r1 = normrnd(mu1(1), sigma1(1), num_samples,1); % generate
r2 = normrnd(mu1(2), sigma1(2), num_samples,1);
cl = class*ones(num_samples, 1);
X = [r1, r2, cl];  % data in the format [feature1, feature2, class]

figure(1);
plot( X(:,1), X(:,2), 'ro');
hold on;

class = 2;
mu2 = [4, 3];    % means
sigma2 = [1, 3]; % standard deviations
r1 = normrnd(mu2(1), sigma2(1), num_samples,1);
r2 = normrnd(mu2(2), sigma2(2), num_samples,1);
cl = class*ones(num_samples, 1);
Y = [r1, r2, cl];

plot( Y(:,1), Y(:,2), 'bx');
hold off;
axis( [-space_limit space_limit -space_limit space_limit]);
xlabel('Feature 1');
ylabel('Feature 2');

data = [X; Y]; % this is our training data

CLASSIFICATION_LEARNER_MODEL = true; % you can switch to the CL App and train the model there
return


%% Train the model using fitsvm     
% Or skip this part and train in the CL App; 
%     -- import the variable called 'data' into the CL App (New Session - from workspace)
%     -- select the Linear SVM model and click the Train button
%     -- then export the model to the workspace as 'trainedModel'
% Run this cell by pressing <cntr> + <enter>

CLASSIFICATION_LEARNER_MODEL = false;
trainedModel = fitcsvm(data(:,1:end-1), data(:,end)); %,'Standardize',true,'KernelFunction','gaussian');%);,'KernelScale','auto'

% classOrder = trainedModel.ClassNames;
beta = trainedModel.Beta; % Linear predictor coefficients
b = trainedModel.Bias; % Bias term

sv = trainedModel.SupportVectors;
figure(2);
gscatter(data(:,1),data(:,2),data(:,3))
hold on
plot(sv(:,1),sv(:,2),'ko','MarkerSize',12)

X1 = linspace(-space_limit,space_limit,100);
X2 = -(beta(1)/beta(2)*X1)-b/beta(2);

idx = find( X2 >= -space_limit & X2 <= space_limit);
X1 = X1(idx);
X2 = X2(idx);
plot(X1,X2,'-')
axis( [-space_limit space_limit -space_limit space_limit]);
hold off;
legend('class 1','class 2','Support Vector', 'Separating Line')

trainedModelcv = crossval(trainedModel); % this is the cross-validated classifier.
classLoss = kfoldLoss(trainedModelcv) % Estimate the out-of-sample misclassification rate.

return

%% Using the model called trainedModel from either above (trained using fitcsvm) or from the classification learner
%  Run this cell by pressing <cntr> + <enter>

% Let's create new data uniformly distributed over the space
X = [];
incr = 0.25;
for r = -space_limit:incr:space_limit
    for c = -space_limit:incr:space_limit
        X = [X; r, c];
    end
end

% predict using the trained model and display class regions
if CLASSIFICATION_LEARNER_MODEL
    yfit = trainedModel.predictFcn(X);
else
    yfit = predict(trainedModel, X);
end

figure(2); clf; hold on;
for i = 1 : size(X,1)
    if yfit(i) == 1
        plot( X(i,1), X(i,2), 'ro');
    else
        plot( X(i,1), X(i,2), 'bx');
    end
end
axis( [-space_limit space_limit -space_limit space_limit]);
hold off;
title('Response classes');



% create new data with the same distribution as the original training data
class = 1;
r1 = normrnd(mu1(1), sigma1(1), num_samples, 1);
r2 = normrnd(mu1(2), sigma1(2), num_samples, 1);
cl = class*ones(num_samples, 1);
X = [r1, r2, cl];
figure(3);
plot( X(:,1), X(:,2), 'ro');
hold on;

class = 2;
r1 = normrnd(mu2(1), sigma2(1), num_samples, 1);
r2 = normrnd(mu2(2), sigma2(2), num_samples, 1);
cl = class*ones(num_samples, 1);
Y = [r1, r2, cl];

plot( Y(:,1), Y(:,2), 'bx');
hold off;
axis( [-space_limit space_limit -space_limit space_limit]);
title('Test Data');

test_data = [X(:,1:2); Y(:,1:2)]; % this is our test data

% predict using the trained model
if CLASSIFICATION_LEARNER_MODEL
    yfit = trainedModel.predictFcn(test_data);
else
    yfit = predict(trainedModel, test_data);
end

figure(4); clf; hold on;
for i = 1 : size(test_data,1)
    if yfit(i) == 1
        plot( test_data(i,1), test_data(i,2), 'ro');
    else
        plot( test_data(i,1), test_data(i,2), 'bx');
    end
end
axis( [-space_limit space_limit -space_limit space_limit]);
hold off;
title('Response classes');
    
fprintf('Accuracy (test data) : %5.3f\n', sum(yfit == [X(:,3);Y(:,3)])/length(yfit) );
