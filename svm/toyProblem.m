% toyProblem.m
% Written by Matthew Boutell, 2006.
% Feel free to distribute at will.

clear all;

% We fix the seeds so the data sets are reproducible
seedTrain = 137;
seedTest = 138;
% This tougher data set is commented out.
%[xTrain, yTrain] = GenerateGaussianDataSet(seedTrain);
%[xTest, yTest] = GenerateGaussianDataSet(seedTest);

% This one isn't too bad at all
[xTrain, yTrain] = GenerateClusteredDataSet(seedTrain);

% Add your code here.
% KNOWN ISSUE: the linear decision boundary doesn't work 
% for this data set at all. Don't know why...
numpoints = size(xTrain, 1);
numdimensions = size(xTrain, 2);
%net = svm(numdimensions, 'rbf', [1], 10);
net = svm(numdimensions, 'rbf', 5, 100);
net = svmtrain(net, xTrain, yTrain);

% Run this on a trained network to see the resulting boundary 
% (as in the demo)
plotboundary(net, [0,20], [0,20]);

[xTest, yTest] = GenerateClusteredDataSet(seedTest);

[detectedClasses, distances] = svmfwd(net, xTest);
truePos = 0;
falseNeg = 0;
falsePos = 0;
trueNeg = 0;
for i = 1:length(yTest)
    actual = yTest(i);
    detect = detectedClasses(i);
    if (actual == 1)
        if (actual == detect)
            truePos = truePos + 1;
        else
            falseNeg = falseNeg + 1;
        end
    else
        if (actual ~= detect)
            falsePos = falsePos + 1;
        else
            trueNeg = trueNeg + 1;
        end
    end
end
fprintf('True Positives: \t%d\n', truePos);
fprintf('False Negatives:\t%d\n', falseNeg);
fprintf('False Positives:\t%d\n', falsePos);
fprintf('True Negatives: \t%d\n', trueNeg);
TPR = truePos/(truePos + falseNeg);
fprintf('TPR: \t%d\n', TPR);
FPR = falsePos/(falsePos + trueNeg);
fprintf('FPR: \t%d\n', FPR);

