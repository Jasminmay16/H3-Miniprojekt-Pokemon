import { useState, useEffect } from "react";
import Pokemon from "./Pokemon";

const API_URL = "https://h3-silvermagicians-backend.mercantec.tech/api/pokemon";

export default function PokemonGrid() {
      const [pokemon, setPokemon] = useState(null);
      const [error, setError] = useState(null);
    
    
      useEffect(() => {
        // Aborting on cleanup stops a slow response from overwriting a newer one.
        const controller = new AbortController();
    
        fetch(API_URL, { signal: controller.signal })
          .then((res) => {
            if (!res.ok) {
              throw new Error(`Request failed with status ${res.status}`);
            }
            return res.json();
          })
          .then((data) => {
            setPokemon(data);
            setError(null);
          })
          .catch((error) => {
            if (error.name === "AbortError") return;
            console.error("Error fetching Pokemon:", error);
            setError(error);
          });
    
        return () => controller.abort();
      }, []);
    
    
      if (error) {
        return <p>Error fetching Pokemon: {error.message}</p>;
      }
    
      if (!pokemon) {
        return <p>Loading...</p>;
      }
    
      return (
        <>
          <div className="pokemon-list">
          {pokemon.sort((a, b) => a.id - b.id).map((p) => (
            <Pokemon key={p.id} pokemon={p}></Pokemon>
          ))}
          </div>
        </>
      );
}