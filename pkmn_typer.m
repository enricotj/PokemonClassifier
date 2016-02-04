function [] = pkmn_typer()
    if(exist('pkmn.mat','file') > 0)
        load('pkmn.mat');
    else
        disp('loading: Type data');
        pkmnTypes = loadPkmnTypes('pokemon\data\pokemon_types.csv');
        disp('loading: Name data');
        [typeNames, pkmnNames] = loadNames('pokemon\data\types.csv', ...
            'pokemon\data\pokemon_species.csv');
        printTypes(pkmnNames,pkmnTypes,typeNames);
        disp('loading: Gen I');
        gen1 = loadPkmn('pokemon\gen1');
        disp('loading: Gen II');
        gen2 = loadPkmn('pokemon\gen2');
        disp('loading: Gen III');
        gen3 = loadPkmn('pokemon\gen3');
        disp('loading: Gen IV');
        gen4 = loadPkmn('pokemon\gen4');
        disp('loading: Gen V');
        gen5 = loadPkmn('pokemon\gen5');
        disp('loading: Gen VI');
        gen6 = loadPkmn('pokemon\gen6');
        pokemon = [gen1;gen2;gen3;gen4;gen5;gen6];
        % How do we need to normalize the data?
        % save('pkmn.mat', ...
        % 'gen1', 'gen2', 'gen3', 'gen4', 'gen5' ...
        % 'pkmnNames', 'pkmnTypes', 'typeNames');
    end
    
end

function types = loadPkmnTypes(typefile)
   typeRaw = csvread(typefile,1,0,[1,0,1071,2]);
   types = zeros(721,2);
   for i=1:size(typeRaw,1)
       types(typeRaw(i,1),typeRaw(i,3)) = typeRaw(i,2);
   end
end

function [typeNames, pkmnNames] = loadNames(typeFile, nameFile)
    typeRaw = textread(typeFile, '%s','whitespace',',');
    typeNames = typeRaw(6:4:end);
    pkmnRaw = textread(nameFile, '%s','whitespace',',');
    pkmnNames = pkmnRaw(5:3:end);
end

function [] = printTypes(pkmnNames,pkmnTypes,typeNames)
    for i=1:size(pkmnNames)
        out(1) = pkmnNames(i);
        out(2) = typeNames(pkmnTypes(i,1));
        if(pkmnTypes(i,2) > 0)
            out(3) = typeNames(pkmnTypes(i,2));
        else
            out(3) = cellstr('');
        end
        disp(out);
    end
end

function genData = loadPkmn(gen_dir)
    files = dir(gen_dir);
    fileIndex = find(~[files.isdir]);
    
    dim = 0; % How many features are we using?
    genData = zeros(size(fileIndex,2), dim);
    for i=1:size(fileIndex,2)
        fileName = strcat(gen_dir,'\',files(fileIndex(i)).name);
        img = imread(fileName);
        % disp(fileName);
        
        % What features do we want to extract?
    end
end