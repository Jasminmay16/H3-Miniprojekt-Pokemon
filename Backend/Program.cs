using Backend.Services;

var builder = WebApplication.CreateBuilder(args);
IConfiguration configuration = builder.Configuration;

string connectionString = configuration.GetConnectionString("PokemonDB") ??
                          throw new Exception("Connection string is not set");

builder.Services.AddControllers();
builder.Services.AddHttpClient<PokemonService>(httpClient =>
{
    httpClient.BaseAddress = new Uri("https://api-opgaver.mercantec.tech");
});

// Re-register with the connection string. The typed client's HttpClient is still injected correctly:
builder.Services.AddTransient(sp =>
    new PokemonService(sp.GetRequiredService<IHttpClientFactory>().CreateClient(nameof(PokemonService)),
        connectionString));
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();

app.UseCors();
app.MapControllers();

app.Run();