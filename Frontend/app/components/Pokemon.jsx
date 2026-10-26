import PokemonType from "./PokemonType";
import PokemonSize from "./PokemonSize";

export default function Pokemon({ pokemon }) {
  return (
    <div className="pokemon" data-liked={pokemon.liked} data-disliked={pokemon.disliked} id={"pokemon-" + pokemon.id}>
        <p className="pokemon-id">ID: {pokemon.id}</p>
        <p className="pokemon-name">{pokemon.name.toUpperCase()}</p>
        <img src={"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/" + pokemon.id + ".png"} alt={pokemon.name} />
        <div className="pokemon-types">
          {pokemon.types.map((type) => (
            <PokemonType key={type} type={type} />
          ))}
        </div>
        <div className="pokemon-sizes">
            <PokemonSize sizeName="Height" sizeValue={pokemon.height} />
            <PokemonSize sizeName="Weight" sizeValue={pokemon.weight} />
        </div>
        <p className="pokemon-like-status">
            {pokemon.liked && "Liked"}
            {pokemon.disliked && "Disliked"}
            {!pokemon.liked && !pokemon.disliked && "No Status"}
        </p>
    </div>
  );
}