maxSig = -999999999;
maxC = -999999999;
maxVal = 0;

% sigma C avgAcc
data = [];
for a=1:5
    for b=100:110
        sig = a/10 + 4.8;
        C = b;
        val = run_svm(sig, C, 0, [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18], 1.5, 1, 1, 1, 0);
        data = vertcat(data, [sig C val]);
        if (val > maxVal)
            maxSig = sig;
            maxC = C;
            maxVal = val;
        end
    end
end

%save('test_svm_coarse', 'data');
save('test_svm_fine', 'data');

% sigma = 0.36
% C = 5.11

disp(maxSig);
disp(maxC);
disp(maxVal);
