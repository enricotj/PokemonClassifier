function X = imageFolderReader(subdir)
    fileList = dir(subdir);
    numFiles = size(fileList, 1);
    
    % files 1 and 2 are . (current dir) and .. (parent dir), respectively, 
    % so we start with 3.
    X=zeros(numFiles-2,294);
    for i=3:numFiles
        filename=[subdir  '/'  fileList(i).name];
        %disp(filename);
        img = imread(filename);
        fv = getFeatureVector(img);
        X(i-2,:)=fv;
    end
end


function fv = getFeatureVector(img)
    fv = zeros(294, 1);
    % TODO
end