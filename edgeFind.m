% Authors: Orion Martin, Joshua Maurer
% img should be the filepath to the image.
function[] = edgeFind(img)
    % Get the six matrices
    % Note - the original output is good on our test image,
    % so no scaling was applied.
    grey = rgb2gray(imread(img));
    [h,v,s,gm,gd,ds] = sobel(grey);
    imtool(uint8(h));
    imtool(uint8(v));
    imtool(uint8(s));
    imtool(uint8(gm));
    gdClean = uint8((gd+pi) * 128/pi);
    imtool(gdClean);
    dsClean = uint8((ds+pi) * 128/pi);
    imtool(dsClean);
    
    % A colorized edge-direction, distinguishing non-edges (blue)
    % from edges (red to green spectrum)
    clear coldir;
    coldir(:,:,1) = dsClean;
    coldir(:,:,2) = 255 - dsClean;
    coldir(:,:,3) = (gm <= 50) * 255;
    imtool(coldir);
    
    % Save images to a dedicated folder
    [imloc, imname, imext] = fileparts(img);
    mkdir(imloc,imname);
    imwrite(uint8(h),strcat(imloc, '\', imname, '\', imname, '_edgeH', imext));
    imwrite(uint8(v),strcat(imloc, '\', imname, '\', imname, '_edgeV', imext));
    imwrite(uint8(s),strcat(imloc, '\', imname, '\', imname, '_edge', imext));
    imwrite(uint8(gm),strcat(imloc, '\', imname, '\', imname, '_gradMag', imext));
    imwrite(gdClean,strcat(imloc, '\', imname, '\', imname, '_gradDir', imext));
    imwrite(dsClean,strcat(imloc, '\', imname, '\', imname, '_dir', imext));
end

% grey should be a greyscale image.
function [horiz,vert,sum,gradMag,gradDir,dirStrong] = sobel(grey)
    sobelH = [-1 0 1;-2 0 2;-1 0 1]/8;
    sobelV = [1 2 1;0 0 0;-1 -2 -1]/8;
    horiz = filter2(sobelH, grey);
    vert = filter2(sobelV, grey);
    sum = horiz + vert;
    gradMag = sqrt(horiz.^2 + vert.^2);
    gradDir = atan2(vert, horiz);
    minDir = 50;    % defined by trial and error
    dirStrong = zeros(size(grey));
    dirStrong(gradMag > minDir) = gradDir(gradMag > minDir);
end