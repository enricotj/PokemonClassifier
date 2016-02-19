% run_svm(0.36, 6, 0, [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18], 3, 1, 3, 6.5);

function avg = run_svm(sigma, C, threshold, types, colorScale, edgeScale, circleScale, cornerScale)
    %delete('pkmn.mat');
    pkmn_typer();
    load('pkmn.mat');
    targets = targets(:, 1:size(pokemon, 2));
    
    pokemon(1:20,:) = pokemon(1:20,:) * colorScale;
    pokemon(21:22,:) = pokemon(21:22,:) * edgeScale;
    pokemon(23,:) = pokemon(23,:) * circleScale;
    pokemon(24,:) = pokemon(24,:) * cornerScale;

    % split training and test data
    trainFeatures = pokemon(:, trainMap);
    trainTargets = targets(:, trainMap);
    testFeatures = pokemon;
    testFeatures(:,trainMap) = [];
    testTargets = targets;
    testTargets(:,trainMap) = [];

    % transpose the data so that it is compatible with SVM
    trainFeatures = transpose(trainFeatures);
    trainTargets = transpose(trainTargets);
    testFeatures = transpose(testFeatures);
    testTargets = transpose(testTargets);

    totalAcc = 0;
    totalTpr = 0;
    warning('off','all')
    allDists = [];
    for t=1:size(types,2)
        i = types(t);
        trainX = trainFeatures;
        trainY = (-1)*(ones(size(trainX, 1),1));
        posTrainMap = find(trainTargets(:, i) == 1);
        trainY(posTrainMap) = 1;
        
        testX = testFeatures;
        testY = (-1)*(ones(size(testX, 1),1));
        posTestMap = find(testTargets(:, i) == 1);
        testY(posTestMap) = 1;
        
%         truePosRate = zeros(1, 201);
%         falsePosRate = zeros(1, 201);
%         for t=-100:100
%             [TPR,FPR,ACC,dists] = trainTest(trainX, trainY, testX, testY, sigma, C, t);
%             truePosRate(t+101) = TPR;
%             falsePosRate(t+101) = FPR;
%         end
%         plotRoc(truePosRate, falsePosRate, typeNames{i});
        [TPR,FPR,ACC,dists] = trainTest(trainX, trainY, testX, testY, sigma, C, threshold);
        allDists = horzcat(allDists, dists);
        %fprintf('********************\n');
        %fprintf('%s\n', typeNames{i});
        %fprintf('TPR: %4.4f\t\t', TPR*100);
        %fprintf('FPR: %4.4f\t\t', FPR*100);
        %fprintf('ACC: %4.4f\n', ACC*100);
        totalAcc = totalAcc + ACC*100;
        totalTpr = totalTpr + TPR*100;
    end
    warning('on','all')
    avgAcc = totalAcc / size(types, 2);
    avgTpr = totalTpr / size(types, 2);
    avg = avgTpr;
    compareMaxDistsToTargets(allDists, testTargets);
end

function compareMaxDistsToTargets(dists, targets)
    correct = 0;
    incorrect = 0;
    for pok=1:size(dists,1)
        [vals,inds] = max(dists(pok,:));
        if (targets(pok,inds(1)) == 1)
            correct = correct + 1;
        else
            incorrect = incorrect + 1;
        end
    end
    %disp(correct);
    %disp(incorrect);
    %disp(correct/(correct + incorrect));
end

function [TPR, FPR, ACC, distances] = trainTest(trainX, trainY, testX, testY, sigma, C, threshold)
    numdimensions = size(trainX, 2);
    net = svm(numdimensions, 'rbf', sigma, C);
    net = svmtrain(net, trainX, trainY);
    
    [detected , distances] = svmfwd(net, testX);
    truePos = 0;
    falseNeg = 0;
    falsePos = 0;
    trueNeg = 0;

    for j = 1:length(testY)
        dist = distances(j);
        actual = testY(j);

        if (dist >= threshold)
            detect = 1;
        else
            detect = -1;
        end

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
    TPR = truePos/(truePos + falseNeg);
    FPR = falsePos/(falsePos + trueNeg);
    ACC = (truePos + trueNeg)/(truePos+falseNeg+falsePos+trueNeg);
    
end

function plotRoc(truePosRate, falsePosRate, name)
    % Create a new figure. You can also number it: figure(1)
    figure;
    % Hold on means all subsequent plot data will be overlaid on a single plot
    hold on;
    % Plots using a blue line (see 'help plot' for shape and color codes 
    plot(falsePosRate, truePosRate, 'b-', 'LineWidth', 2);
    % Overlaid with circles at the data points
    plot(falsePosRate, truePosRate, 'bo', 'MarkerSize', 6, 'LineWidth', 2);

    % Title, labels, range for axes
    title(name, 'fontSize', 18);
    xlabel('False Positive Rate', 'fontWeight', 'bold');
    ylabel('True Positive Rate', 'fontWeight', 'bold');
    % TPR and FPR range from 0 to 1. You can change these if you want to zoom in on part of the graph.
    axis([0 1 0 1]);
end

function result = normalizesDists(dists)
    for i=1:size(dists,2)
        mn = min(dists(:, i));
        mx = max(dists(:, i));
        dists(:,i) = (dists(:, i) - mn) / mx;
    end
    result = dists;
end