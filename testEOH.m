[img,map,alpha] = imread('pokemon/gen1/109.png');

gray = ind2gray(img,map);
white = gray;
white(find(white > 0)) = 1;
rp = regionprops(white,'BoundingBox');
bb = rp.BoundingBox;
c = uint8(bb(1));
r = uint8(bb(2));
w = uint8(bb(3));
h = uint8(bb(4));
croppedGray = gray(r:(r+h-1),c:(c+w-1));
eoh = transpose(edgeOrientationHistogram(croppedGray, 5));
