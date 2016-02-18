%
% [eoh] = edgeOrientationHistogram(im)
%
% Extract the MPEG-7 "Edge Orientation Histogram" descriptor
% 
% Input image should be a single-band image, but if it's a multiband (e.g. RGB) image
% only the 1st band will be used.
% Compute 4 directional edges and 1 non-directional edge
% The output "eoh" is a 4x4x5 matrix
%
% The image is split into 4x4 non-overlapping rectangular regions
% In each region, a 1x5 edge orientation histogram is computed (horizontal, vertical,
% 2 diagonals and 1 non-directional)
%
% parameters
% - the image
% - the number of vertical and horizontal divisions
function [data] = edgeOrientationHistogram(im, r)

    % define the filters for the 5 types of edges
    f2 = zeros(3,3,5);
    f2(:,:,1) = [1 2 1;0 0 0;-1 -2 -1];
    f2(:,:,2) = [-1 0 1;-2 0 2;-1 0 1];
    f2(:,:,3) = [2 2 -1;2 -1 -1; -1 -1 -1];
    f2(:,:,4) = [-1 2 2; -1 -1 2; -1 -1 -1];
    f2(:,:,5) = [-1 0 1;0 0 0;1 0 -1];

    % the size of the image
    ys = size(im,1);
    xs = size(im,2);

    % Build a new matrix of the same size of the image
    % and 5 dimensions to save the gradients
    im2 = zeros(ys,xs,5);

    % iterate over the posible directions
    for i = 1:5
        % apply the sobel mask
        im2(:,:,i) = filter2(f2(:,:,i), im);
    end

    % calculate the max sobel gradient
    [mmax, maxp] = max(im2,[],3);
    % save just the index (type) of the orientation
    % and ignore the value of the gradient
    im2 = maxp;

    % detect the edges using the default Octave parameters
    ime = edge(im, 'canny');

    % multiply against the types of orientations detected
    % by the Sobel masks
    im2 = im2.*ime;

    % produce a structur to save all the bins of the
    % histogram of each region
    eoh = zeros(r,r,6);
    % for each region
    for j = 1:r
        for i = 1:r
            % extract the subimage
            clip = im2(round((j-1)*ys/r+1):round(j*ys/r),round((i-1)*xs/r+1):round(i*xs/r));
            % calculate the histogram for the region
            eoh(j,i,:) = (hist(makelinear(clip), 0:5)*100)/numel(clip);
        end
    end

    % take out the zeros
    eoh = eoh(:,:,2:6);

    % represent all the histograms on one vector
    data = zeros(1,numel(eoh));
    data(:) = eoh(:);
end

function arr = makelinear(mat)
    arr = reshape(mat, 1, size(mat,1)*size(mat,2));
end