import Navigation from "../components/Navigation.jsx";
import PokemonGrid from "../components/PokemonGrid.jsx";

export function meta({}) {
  return [
    { title: "Pokemon Tinder" },
    { name: "description", content: "Find your favorite Pokemon!" },
  ];
}

export default function Home() {


  return (
    <>
      <Navigation />
      <h1>Pokemon</h1>
      <PokemonGrid/>
    </>
  );
}
