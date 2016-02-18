function pkmn_train()
    disp('loading: normal');
    normal = loadPkmn('training\01_normal');
    disp('loading: fighting');
    fighting = loadPkmn('training\02_fighting');
    disp('loading: flying');
    flying = loadPkmn('training\03_flying');
    disp('loading: poison');
    poison = loadPkmn('training\04_poison');
    disp('loading: ground');
    ground = loadPkmn('training\05_ground');
    disp('loading: rock');
    rock = loadPkmn('training\06_rock');
    disp('loading: bug');
    bug = loadPkmn('training\07_bug');
    disp('loading: ghost');
    ghost = loadPkmn('training\08_ghost');
    disp('loading: steel');
    steel = loadPkmn('training\09_steel');
    disp('loading: fire');
    fire = loadPkmn('training\10_fire');
    disp('loading: water');
    water = loadPkmn('training\11_water');
    disp('loading: grass');
    grass = loadPkmn('training\12_grass');
    disp('loading: electric');
    electric = loadPkmn('training\13_electric');
    disp('loading: psychic');
    psychic = loadPkmn('training\14_psychic');
    disp('loading: ice');
    ice = loadPkmn('training\15_ice');
    disp('loading: dragon');
    dragon = loadPkmn('training\16_dragon');
    disp('loading: dark');
    dark = loadPkmn('training\17_dark');
    disp('loading: fairy');
    fairy = loadPkmn('training\18_fairy');
    training = [normal fighting flying poison ground rock bug ghost steel fire water grass electric psychic ice dragon dark fairy];
    training = pkmnNormalize(training);
    save('pkmn_train.mat', 'training', 'trainingTargets');
    disp(size(training));
    disp(size(trainingTargets));
end