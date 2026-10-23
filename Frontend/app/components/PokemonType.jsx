export default function PokemonType({ type }) {
  return (
    <span className="pokemon-type" data-type={type}>{type.toUpperCase()}</span>
  );
}