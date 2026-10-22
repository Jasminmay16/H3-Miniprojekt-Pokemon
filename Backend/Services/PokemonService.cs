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

    // public async Task<Pokemon> GetPokemonJsonAsync(int id)
    // {
    //     string connstr = _config.GetConnectionString("PokemonDB")!;
    //     await using var conn = new NpgsqlConnection(connstr);
    //     await conn.OpenAsync();
        
    //     await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetPokemonById(@id)", conn))
    //     {
    //         cmd.Parameters.AddWithValue("id", id);
    //         NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();  
    //     }
    // }

    public async Task<Pokemon> GetRandomNonLikedPokemon()
    {
        string connstr = _config.GetConnectionString("PokemonDB")!;
        await using var conn = new NpgsqlConnection(connstr);
        await conn.OpenAsync();

        List<Pokemon> pokemons = new List<Pokemon>();
        await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetAllPokemonWithNoLikesOrDislikes()", conn))
        {
            NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            while (await DBcall.ReadAsync())
            {
                pokemons.Add(new Pokemon
                {
                    Id = DBcall.GetInt32(0),
                    Name = DBcall.GetString(1),
                });
                Console.WriteLine(DBcall.GetInt32(0));
                Console.WriteLine(DBcall.GetString(1));
            }

            foreach(Pokemon pokemon in pokemons)
            {
                Console.WriteLine(pokemon.Name);
            }
            Console.WriteLine(pokemons.First().Name);

            return pokemons.First();
        }
    }

    public async Task<Pokemon> GetLikedPokemonAsync(int id)
    {
        var response = await _httpClient.GetAsync($"{PokemonApiUrl}like/{id}");
        var json = await response.Content.ReadAsStringAsync();
        var pokemonObject = JsonSerializer.Deserialize<Pokemon>(json);
        pokemonObject.Liked = true;

       await SaveToDatabase(pokemonObject);
       return pokemonObject;
    }

    public async Task<List<Pokemon>> GetAllLikedPokemonAsync()
    {
        //Call database
        string connstr = _config.GetConnectionString("PokemonDB")!;
        await using var conn = new NpgsqlConnection(connstr);
        await conn.OpenAsync();
        
        await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetAllLikedPokemon()", conn))
        {
            NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            List<Pokemon> pokemons = new List<Pokemon>();
            while (DBcall.Read())
            {
                pokemons.Append( new Pokemon
                {
                    Id = DBcall.GetInt32(0),
                    Name = DBcall.GetString(1),
                    Types =
                    [
                        DBcall.GetString(2),
                        DBcall.GetString(3)
                    ],
                    Height = DBcall.GetDouble(4),
                    Weight = DBcall.GetDouble(5),
                    Liked = DBcall.GetBoolean(6),
                    Disliked = DBcall.GetBoolean(7)
                    
                });
            }
            return pokemons;
        }
    }

    public async Task<List<Pokemon>> PostPokemonJsonToDBAsync()
    {
        var response = await _httpClient.GetAsync(PokemonApiUrl);
        var json = await response.Content.ReadAsStringAsync();
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
            cmd.Parameters.AddWithValue("type2", pokeObj.Types.Length > 1 ? pokeObj.Types[1] : DBNull.Value);
            cmd.Parameters.AddWithValue("height", pokeObj.Height);
            cmd.Parameters.AddWithValue("weight", pokeObj.Weight);
            await cmd.ExecuteNonQueryAsync();
        }

    }
}
