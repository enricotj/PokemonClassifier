function findBestVariables()
    avgMax = 0;
    for sig = .5:.5:10 
        for c = 10:10:30
            disp(c)
            for color = 0:5
                for e = 0:5
                    for cir = 0:5
                        for cor = 0:5
                            avg = run_svm(sig, c, 0, [3], color, e, cir, cor);
                            if(avg > avgMax)
                                avgMax = avg 
                                 fprintf('sig: %d c: %d color: %d edge: %d circle: %d corner: %d\n', ...
                                     sig,c,color,e,cir,cor);
                            end
                        end
                    end
                end
            end
        end
    end
end