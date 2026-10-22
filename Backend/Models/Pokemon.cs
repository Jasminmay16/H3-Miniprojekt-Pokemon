using System.Text.Json.Serialization;

namespace Backend.Models;

public class Pokemon
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; }

    [JsonPropertyName("types")]
    public string[] Types { get; set; } = [];

    [JsonPropertyName("height")]
    public double Height { get; set; }

    [JsonPropertyName("weight")]
    public double Weight { get; set; }
    
    public bool Liked { get; set; }
    public bool Disliked { get; set; }
}
