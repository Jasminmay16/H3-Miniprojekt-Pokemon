namespace Backend.Models;

public class Pokemon
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string[] Types { get; set; } = [];
    public double Height { get; set; }
    public double Weight { get; set; }
    public bool Liked { get; set; }
    public bool Disliked { get; set; }
}
