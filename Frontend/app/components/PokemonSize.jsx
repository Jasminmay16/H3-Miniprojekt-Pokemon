export default function PokemonSize({ sizeName, sizeValue }) {
    return (
        <p className="pokemon-size">
            <span>{sizeName}</span>
            <span className="pokemon-size-value">{sizeValue}</span>
        </p>
    );
}