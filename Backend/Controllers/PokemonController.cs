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
    public async Task<IActionResult> GetAllPokemon()
    {
        var json = await _pokemonService.GetAllPokemonJsonAsync();
        return Content(json, "application/json");
    }

    // [HttpGet("{id}")]
    // public async Task<IActionResult> GetPokemon(int id)
    // {
    //     var json = await _pokemonService.GetPokemonJsonAsync(id);
    //     return Content(json, "application/json");
    // }

    [HttpGet("random")]
    public async Task<IActionResult> GetRandomPokemon() =>
         Ok(await _pokemonService.GetRandomNonLikedPokemon());

    // [HttpGet("like/{id}")]
    // public async Task<IActionResult> PostLikedPokemon(int id) => 
    //     Ok(await _pokemonService.PostLikedPokemonAsync(id));

    [HttpPost]
    public async Task<IActionResult> PostPokemonToDB() => 
        Ok(await _pokemonService.PostPokemonJsonToDBAsync());
    
    //Get Liked(ID)

    //Get Disliked(ID)
}
