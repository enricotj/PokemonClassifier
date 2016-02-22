% uncomment to re-extract training names from 'training/all'
%extractTrainingNames();

% uncomment to remake pkmn.mat features
%delete('pkmn.mat');
%pkmn_typer();

load('pkmn.mat');
trials = 1;
for i=1:trials
    run_svm(5, 107, 0, [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18], 1.5, 1, 1, 1, 0);
    %nnetClassify(pokemon, targets(:, 1:649), 0, 0, 100, typeNames, 70);
    %nnetClassifyStandardTraining(pokemon, targets(:, 1:649), 0, 0, 100, typeNames, 70);
end