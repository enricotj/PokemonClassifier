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
        [gen1, train1] = loadPkmn('pokemon\gen1', 0);
        disp('loading: Gen II');
        [gen2, train2] = loadPkmn('pokemon\gen2', size(gen1, 2));
        disp('loading: Gen III');
        [gen3, train3] = loadPkmn('pokemon\gen3', size(gen1,2)+size(gen2,2));
        disp('loading: Gen IV');
        [gen4, train4] = loadPkmn('pokemon\gen4', size(gen1,2)+size(gen2,2)+size(gen3, 2));
        disp('loading: Gen V');
        [gen5, train5] = loadPkmn('pokemon\gen5', size(gen1,2)+size(gen2,2)+size(gen3,2)+size(gen4, 2));
%         disp('loading: Gen VI');
%         gen6 = loadPkmn('pokemon\gen6');
        
        % How do we need to normalize the data?
        pokemon = [gen1 gen2 gen3 gen4 gen5];
        pokemon = pkmnNormalize(pokemon);
        typeNames(19) = {'all'};
        trainMap = [train1 train2 train3 train4 train5];
        save('pkmn.mat', 'pokemon', 'targets', 'typeNames', 'trainMap', 'pkmnNames');
%         save('pkmn.mat', ...
%         'gen1', 'gen2', 'gen3', 'gen4', 'gen5' ...
%         'pkmnNames', 'pkmnTypes', 'typeNames');
    end
    
end

function [genData, trainMap] = loadPkmn(gen_dir, prevGenSize)
    warning('off','all')
    files = dir(gen_dir);
    fileIndex = find(~[files.isdir]);
    
    ncolors = 5; % number of colors to use in the cfv
    ncf = 4; % number of color features per ncolors
    cfvSize = ncolors*ncf;
    efvSize = 2;
    %dim = 4*cfvSize + efvSize; % How many features are we using?
    %genData = zeros(size(fileIndex,2), dim);
    genData = [];
    trainMap = [];
    for i=1:size(fileIndex,2)
        fileName = strcat(gen_dir,'\',files(fileIndex(i)).name);
        [pathstr,name,ext] = fileparts(fileName);
        if (strcmp(ext,'.txt'))
            continue;
        end
        if (isTraining(name) == 1)
            key = i + prevGenSize;
            trainMap = [trainMap key];
        end
        [img, map, alpha] = imread(fileName);
        
%         F(size(map,1)) = struct('cdata',[],'colormap',[]);
%         for i = 1:size(map,1)
%             togif = img;
%             togif(togif > i) = 0;
%             imshow(imresize(ind2rgb(togif,map),5,'nearest'));
%             drawnow
%             F(i) = getframe;
%         end
%         movie(F,50,5);
        
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
            cfv(c) = lstmap(ind, 1);  % L
            cfv(c+1) = lstmap(ind, 2);  % S
            cfv(c+2) = lstmap(ind, 3);  % T
            cfv(c+3) = weights(ind);      % weight
        end
        %cfv(cfvSize, 1) = size(map, 1) - 1;
        
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
        %imtool(d/6.28+0.5);
        
        % Circularity measure: bodyEcc
        % ecc.Eccentricity = 0 => circle
        % ecc.Eccentricity = 1 => line
        dat = regionprops(img > 0,'Eccentricity','Area');
        [M,ind] = max([dat.Area]);
        ecc = [dat.Eccentricity];
        bodyEcc = ecc(ind);        
        efv(2) = bodyEcc;
        
        % Edge Orientation Histogram
%         white = img;
%         white(find(white > 0)) = 1;
%         rp = regionprops(white,'BoundingBox');
%         bb = rp.BoundingBox;
%         c = uint8(bb(1));
%         r = uint8(bb(2));
%         w = uint8(bb(3));
%         h = uint8(bb(4));
%         croppedGray = gray(r:(r+h-1),c:(c+w-1));
%         eoh = transpose(edgeOrientationHistogram(croppedGray, 5));
        
        d = d(2:95,2:95);
        [eoh, bins] = hist(d(d ~= 0));
%         xlabel('Angle (rad)');
%         ylabel('Occurences');
%         title('Voltorb - Electric Type');
        eoh = transpose(eoh);
        efv = vertcat(efv, eoh);
        
        % ****************************************************************
        % Circles Data
        % ****************************************************************
        sfv = [];
        rgb = ind2rgb(img, map);
        Rmin = 2;
        Rmax = 32;
        [centersBright, radiiBright] = imfindcircles(rgb,[Rmin Rmax],'ObjectPolarity','bright');
        [centersDark, radiiDark] = imfindcircles(rgb,[Rmin Rmax],'ObjectPolarity','dark');
        % number of circles
        sfv = vertcat(sfv, size(radiiBright, 1) + size(radiiDark, 1));
        
        % ****************************************************************
        % Corners Data
        % ****************************************************************
        cns = corner(gray, 'Harris');
        sfv = vertcat(sfv, size(cns, 1));
%         figure;
%         imshow(rgb);
%         viscircles(centersDark, radiiDark,'LineStyle','--');
%         viscircles(centersBright, radiiBright,'LineStyle','--');
%         hold on
%         plot(cns(:,1), cns(:,2), 'r*');
        
        % ****************************************************************
        % SFTA texture feature extraction
        % ****************************************************************
        % second input to sfta fucntion = 6*nf -3 where nf is the number
        % of desired features
        %sftafv = transpose(sfta(img,5));
        
        % ****************************************************************
        % Combine Feature Vectors
        % ****************************************************************
        fv = vertcat(cfv, efv, sfv);
        genData = horzcat(genData, fv);
    end
    warning('on','all')
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
    %imtool(targets);
end

function result = pkmnNormalize(pokemon)
    for i=1:size(pokemon,1)
        mn = min(pokemon(i, :));
        mx = max(pokemon(i, :));
        pokemon(i, :) = (pokemon(i, :) - mn) / mx;
    end
    result = pokemon;
end