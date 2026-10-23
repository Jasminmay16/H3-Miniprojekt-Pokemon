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
    public async Task<IActionResult> GetAllPokemonFromDB() =>
        Ok(await _pokemonService.GetAllPokemonJsonAsync());


    [HttpGet("random")]
    public async Task<IActionResult> GetRandomPokemon() =>
         Ok(await _pokemonService.GetRandomNonLikedPokemon());


    [HttpGet("like/{id:int}")]
    public async Task<IActionResult> LikedPokemonIntoDB(int id)
    {
        try
        {
            await _pokemonService.GetLikedPokemonAsync(id);
        }
        catch(Exception ex)
        {
            return StatusCode(500, "Internal server error, by liking pokemon");
        }
        return Ok();
    }

    [HttpGet("dislike/{id}")]
    public async Task<IActionResult> DislikedPokemonIntoDB(int id)
    {
        await _pokemonService.GetDislikedPokemonAsync(id);
        return Ok();
    }

    [HttpPost]
    public async Task<IActionResult> PostPokemonToDB() =>
        Ok(await _pokemonService.PostPokemonJsonToDBAsync());
}
