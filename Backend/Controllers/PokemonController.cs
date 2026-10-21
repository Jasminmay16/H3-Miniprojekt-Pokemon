using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class PokemonController : ControllerBase
{
    private readonly PokemonService _pokemonService;

    public PokemonController(PokemonService pokemonService)
    {
        _pokemonService = pokemonService;
    }

    [HttpGet]
    public async Task<IActionResult> GetPokemon()
    {
        var json = await _pokemonService.GetPokemonJsonAsync();
        return Content(json, "application/json");
    }

    //Get ID

    //Get Liked(ID)

    //Get Disliked(ID)
}
