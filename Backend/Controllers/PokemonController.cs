using System.Net; // For HttpStatusCode
using Microsoft.AspNetCore.Http; // For StatusCodes
using Microsoft.AspNetCore.Mvc; // For ControllerBase

[Route("api/[controller]")]
[ApiController]
public class PokemonController : ControllerBase
{
    public string PokemonApi()
    {
        var url = "https://api-opgaver.mercantec.tech/go/pokemon";
        using var client = new HttpClient();
        var res = await client.GetAsync(url);
        res.EnsureSuccessStatusCode();
        var json = await res.Content.ReadAsStringAsync();

        return json;
    }

}