maxSig = -999999999;
maxC = -999999999;
maxVal = 0;
for a=1:10
    for b=1:10
        sig = a/25 + 0.8;
        C = b*10 + 850;
        val = run_svm(sig, C, 0, [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]);
        if (val > maxVal)
            maxSig = sig;
            maxC = C;
            maxVal = val;
        end
    end
end

% sigma = 0.36
% C = 5.11

disp(maxSig);
disp(maxC);
disp(maxVal);
