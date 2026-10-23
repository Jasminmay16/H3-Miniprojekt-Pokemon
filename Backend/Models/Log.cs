using System.Text.Json.Serialization;

namespace Backend.Models;

public class Log
{
    public int Id { get; set; }
    public string Action {get; set;}
    public int? PokemonId {get; set;}
    public string? PokemonName {get; set;}
    public DateTime CreatedAt {get; set;}
}
