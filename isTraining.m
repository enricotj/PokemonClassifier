function check = isTraining(name)
    load('trainingNames.mat');
    check = 0;
    for i=1:size(trainingNames, 1)
        if (strcmp(name, trainingNames(i)))
           check = 1;
           break;
        end
    end
end