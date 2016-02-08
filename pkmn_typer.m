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
        targets = buildTargetMatrix(pkmnTypes);
        
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
%         disp('loading: Gen VI');
%         gen6 = loadPkmn('pokemon\gen6');

        % How do we need to normalize the data?
        pokemon = [gen1 gen2 gen3 gen4 gen5];
        save('pkmn.mat', 'pokemon', 'targets', 'typeNames');
%         save('pkmn.mat', ...
%         'gen1', 'gen2', 'gen3', 'gen4', 'gen5' ...
%         'pkmnNames', 'pkmnTypes', 'typeNames');
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
    
    ncolors = 5; % number of colors to use in the cfv
    ncf = 4; % number of color features per ncolors
    cfvSize = ncolors*ncf + 1;
    efvSize = 2;
    %dim = 4*cfvSize + efvSize; % How many features are we using?
    %genData = zeros(size(fileIndex,2), dim);
    genData = [];
    for i=1:size(fileIndex,2)
        fileName = strcat(gen_dir,'\',files(fileIndex(i)).name);
        [img map alpha] = imread(fileName);
        %imtool(img);
        
        % Get LST-space data
        clear lstmap;
        lstmap(:,1) = (map(:,1) + map(:,2) + map(:,3))/3;
        lstmap(:,2) = (map(:,1) - map(:,3))/2+0.5;
        lstmap(:,3) = (map(:,1) - 2*map(:,2) + map(:,3))/4+0.5;
        % figure, imshow(img,map);
        % What features do we want to extract?
        
        % ****************************************************************
        % Color Data
        % ****************************************************************
        pkmnSize = size(find(img ~= 0), 1);
        weights = zeros(size(map,1), 1);
        for j=2:size(map,1) %ignore first map entry (it's the background)
            num = size(find(img == j), 1);
            weights(j) = num / pkmnSize;
        end
        [wsort I] = sort(weights, 'descend');
        cfv = zeros(cfvSize, 1); % color feature vector
        for j=1:ncolors
            ind = I(j); % get original map index
            c = (j-1)*ncf + 1; % color feature vector index
            cfv(c) = weights(ind);      % weight
            cfv(c+1) = lstmap(ind, 1);  % L
            cfv(c+2) = lstmap(ind, 2);  % S
            cfv(c+3) = lstmap(ind, 3);  % T
        end
        cfv(cfvSize, 1) = size(weights, 1) - 1;
        
        % ****************************************************************
        % Edginess Data
        % ****************************************************************
        % compensate for background color
        efv = zeros(efvSize, 1);
        map(1,:) = [1 1 1];
        gray = ind2gray(img,map);
        
        % Edge
        [h,v,s,gm,gd,d] = sobel(gray);
        edgeTotal = sum(sum(gm(2:95,2:95)));
        efv(1) = edgeTotal;
        
        % Circularity measure: bodyEcc
        % ecc.Eccentricity = 0 => circle
        % ecc.Eccentricity = 1 => line
        dat = regionprops(img > 0,'Eccentricity','Area');
        [M,ind] = max([dat.Area]);
        ecc = [dat.Eccentricity];
        bodyEcc = ecc(ind);
        efv(2) = bodyEcc;
        
        % ****************************************************************
        % SFTA texture feature extraction
        % ****************************************************************
        % second input to sfta fucntion = 6*nf -3 where nf is the number
        % of desired features
        %sftafv = sfta(img,5);
        % ****************************************************************
        % Combine Feature Vectors
        % ****************************************************************
        fv = vertcat(cfv, efv);
        genData = horzcat(genData, fv);
    end
end

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

% add after end of pkmn_typer function
function targets = buildTargetMatrix(typeList)
    % typeList has Pokemon types in a 721x2 matrix.
    targets = zeros(18,721);
    for i=1:721
        targets(typeList(i,1),i) = 1;
        if(typeList(i,2) > 0)
            targets(typeList(i,2),i) = 1;
        end
    end
    imtool(targets);
end