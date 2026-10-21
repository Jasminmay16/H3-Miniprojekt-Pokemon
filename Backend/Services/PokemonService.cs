namespace Backend.Services;

public class PokemonService
{
    private readonly HttpClient _httpClient;
    private const string PokemonApiUrl = "https://api-opgaver.mercantec.tech/go/pokemon";

    public PokemonService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<string> GetPokemonJsonAsync()
    {
        var response = await _httpClient.GetAsync(PokemonApiUrl);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}
