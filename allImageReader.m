% **************************************************************
% NOTE: the following code is just an example from
%       the sunset detector project
% **************************************************************

FVa = imageFolderReader('sunsetDetectorImages/TrainSunset');
astart = 1;
aend = size(FVa, 1);
FVb = imageFolderReader('sunsetDetectorImages/TrainNonsunsets');
bstart = aend + 1;
bend = aend + size(FVb, 1);
FVc = imageFolderReader('sunsetDetectorImages/TestSunset');
cstart = bend + 1;
cend = bend + size(FVc, 1);
FVd = imageFolderReader('sunsetDetectorImages/TestNonsunsets');
dstart = cend + 1;
dend = cend + size(FVd, 1);

FVab = vertcat(FVa, FVb);
FVcd = vertcat(FVc, FVd);
FVabcd = vertcat(FVab, FVcd);
FV = normalizeFeatures01(FVabcd);

% split normalized feature vector back
% into categories for training/testing
Strain = FV(astart:aend, :);
Ntrain = FV(bstart:bend, :);
Stest = FV(cstart:cend, :);
Ntest = FV(dstart:dend, :);

disp('Saving FV, S/Ntrain, S/Ntest, DS/DNtest...');
save('features.mat', 'FV', 'Strain', 'Ntrain', 'Stest', 'Ntest');
disp('Data saved.');







