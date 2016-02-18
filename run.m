delete('pkmn.mat');
pkmn_typer();
load('pkmn.mat');
nnetClassify(pokemon, targets(:, 1:649), 0, 0, 100, typeNames, 50);