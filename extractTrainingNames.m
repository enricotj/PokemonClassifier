function extractTrainingNames()
    trainingDir = 'training/all';
    files = dir(trainingDir);
    fileIndex = find(~[files.isdir]);
    trainingNames = cell(size(fileIndex, 2), 1);
    for i=1:size(fileIndex,2)
        fileName = strcat(trainingDir,'\',files(fileIndex(i)).name);
        [pathstr,name,ext] = fileparts(fileName);
        trainingNames(i) = {name};
    end
    save('trainingNames.mat', 'trainingNames');
end