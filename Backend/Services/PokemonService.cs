using System.Text.Json;
using System.Xml.Linq;
using Backend.Models;
using Microsoft.VisualBasic;
using Npgsql;
using Microsoft.Extensions.Configuration;
using System.Runtime.CompilerServices;

namespace Backend.Services;

public class PokemonService
{
    private readonly HttpClient _httpClient;
    private const string PokemonApiUrl = "https://api-opgaver.mercantec.tech/go/pokemon/";
    private static readonly IConfiguration _config = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional:false, reloadOnChange: false)
    .Build();

    public PokemonService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<string> GetAllPokemonJsonAsync()
    {
        var response = await _httpClient.GetAsync(PokemonApiUrl);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();        
    }

    public async Task<string> GetPokemonJsonAsync(int id)
    {
        var response = await _httpClient.GetAsync($"{PokemonApiUrl}{id}");
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }

    public async Task<Pokemon> PostLikedPokemonAsync(int id)
    {
        var response = await _httpClient.GetAsync($"{PokemonApiUrl}{id}/Liked");
        var json = await response.Content.ReadAsStringAsync();
        var pokemonObject = JsonSerializer.Deserialize<Pokemon>(json);
        pokemonObject.Liked = true;

       await SaveToDatabase(pokemonObject);
       return pokemonObject;
    }

    public async Task<string> GetLikedPokemonAsync()
    {
        //Call database
        string connstr = _config.GetConnectionString("PokemonDB")!;
        await using var conn = new NpgsqlConnection(connstr);
        await conn.OpenAsync();

        //check if pokemon have been liked
        //Get all pokemone which have been liked
        //show the pokemon
        return string.Empty;
    }

    public async Task<List<Pokemon>> PostPokemonJsonToDBAsync()
    {
        var response = await _httpClient.GetAsync(PokemonApiUrl);
        var json = await response.Content.ReadAsStringAsync();
        Console.WriteLine(json);
        var pokemonObjects = JsonSerializer.Deserialize<List<Pokemon>>(json);
        foreach(Pokemon pokemonObject in pokemonObjects)
        {
            await SaveToDatabase(pokemonObject);
        }
        return pokemonObjects;
    }

    public async Task SaveToDatabase(Pokemon pokeObj)
    {
        // Insert some data
        string connstr = _config.GetConnectionString("PokemonDB")!;
        await using var conn = new NpgsqlConnection(connstr);
        await conn.OpenAsync();

        //Change sql to match our database sql
        await using (var cmd = new NpgsqlCommand($"CALL InsertPokemon(@id, @name, @type1, @type2, @height, @weight)", conn))
        {
            cmd.Parameters.AddWithValue("id", pokeObj.Id);
            cmd.Parameters.AddWithValue("name", pokeObj.Name);
            cmd.Parameters.AddWithValue("type1", pokeObj.Types[0]);
            cmd.Parameters.AddWithValue("type2", pokeObj.Types[1]);
            cmd.Parameters.AddWithValue("height", pokeObj.Height);
            cmd.Parameters.AddWithValue("weight", pokeObj.Weight);
            await cmd.ExecuteNonQueryAsync();
        }

    }
}
