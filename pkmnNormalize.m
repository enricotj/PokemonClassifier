function result = pkmnNormalize(pokemon)
    for i=1:size(pokemon,1)
        mn = min(pokemon(i, :));
        mx = max(pokemon(i, :));
        pokemon(i, :) = (pokemon(i, :) - mn) / mx;
    end
    result = pokemon;
end