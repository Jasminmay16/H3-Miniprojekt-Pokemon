using System.Text.Json;
using System.Xml.Linq;
using Backend.Models;
using Microsoft.VisualBasic;
using Npgsql;
using Microsoft.Extensions.Configuration;
using System.Runtime.CompilerServices;

namespace Backend.Services;

public class PokemonService(HttpClient httpClient, string connectionString)
{
    private readonly HttpClient _httpClient = httpClient;
    private readonly string _connectionString = connectionString;

    public async Task<List<Pokemon>> GetAllPokemonJsonAsync()
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();

        List<Pokemon> pokemons = new List<Pokemon>();
        await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetAllPokemon()", conn))
        {
            await using NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            while (DBcall.Read())
            {
                pokemons.Add(new Pokemon
                {
                    Id = DBcall.GetInt32(0),
                    Name = DBcall.GetString(1),
                    Types = DBcall.IsDBNull(3)
                        ? [DBcall.GetString(2)]
                        : [DBcall.GetString(2), DBcall.GetString(3)],
                    Height = DBcall.GetDouble(4),
                    Weight = DBcall.GetDouble(5),
                    Liked = DBcall.GetBoolean(6),
                    Disliked = DBcall.GetBoolean(7)

                });
            }
            return pokemons;
        }
    }

    public async Task<Pokemon> GetRandomNonLikedPokemon()
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();

        List<Pokemon> pokemons = new List<Pokemon>();
        await using (var cmd = new NpgsqlCommand($"SELECT id, name FROM GetAllPokemonWithNoLikesOrDislikes()", conn))
        {
            await using NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            while (await DBcall.ReadAsync())
            {
                pokemons.Add(new Pokemon
                {
                    Id = DBcall.GetInt32(0),
                    Name = DBcall.GetString(1),
                });
            }

            return pokemons.First();
        }
    }

    public async Task GetLikedPokemonAsync(int id)
    {
        
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();

        await using (var cmd = new NpgsqlCommand($"CALL LikePokemon(@id)", conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await cmd.ExecuteNonQueryAsync();
        }
    }

    public async Task GetDislikedPokemonAsync(int id)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();

        await using (var cmd = new NpgsqlCommand($"CALL DislikePokemon(@id)", conn))
        {
            cmd.Parameters.AddWithValue("id", id);
            await cmd.ExecuteNonQueryAsync();
        }
    }

    public async Task<List<Pokemon>> GetAllLikedPokemonAsync()
    {
        //Call database
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();
        
        await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetAllLikedPokemon()", conn))
        {
            await using NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            List<Pokemon> pokemons = new List<Pokemon>();
            while (DBcall.Read())
            {
                pokemons.Add(new Pokemon
                {
                    Id = DBcall.GetInt32(0),
                    Name = DBcall.GetString(1),
                    Types = DBcall.IsDBNull(3)
                        ? [DBcall.GetString(2)]
                        : [DBcall.GetString(2), DBcall.GetString(3)],
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
        var response = await _httpClient.GetAsync("/go/pokemon");
        var json = await response.Content.ReadAsStringAsync();
        var pokemonObjects = JsonSerializer.Deserialize<List<Pokemon>>(json);
        foreach(Pokemon pokemonObject in pokemonObjects)
        {
            await SaveToDatabase(pokemonObject);
        }
        return pokemonObjects;
    }

    public async Task<List<Log>> GetLogs()
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync();

        List<Log> logs = new List<Log>();
        await using (var cmd = new NpgsqlCommand($"SELECT * FROM GetLogEntries()", conn))
        {
            await using NpgsqlDataReader DBcall = await cmd.ExecuteReaderAsync();
            while (DBcall.Read())
            {
                logs.Add(new Log
                {
                    Id = DBcall.GetInt32(0),
                    Action = DBcall.GetString(1),
                    PokemonId = DBcall.GetInt32(2),
                    PokemonName = DBcall.GetString(3),
                    CreatedAt = DBcall.GetDateTime(4)
                });
            }
            return logs;
        }
    }
    private async Task SaveToDatabase(Pokemon pokeObj)
    {
        // Insert some data
        await using var conn = new NpgsqlConnection(_connectionString);
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
