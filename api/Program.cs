using System.Net;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

BancoDeDados banco = new()
{
    Filmes = [
        new Filme
        {
            Id = new Guid("7074da12-167a-43ec-ad3f-601ea448b56b"),
            Titulo = "Jogos Vorazes",
            UrlImagem = "https://upload.wikimedia.org/wikipedia/pt/4/42/HungerGamesPoster.jpg",
            Genero = "Ação & Aventura",
            FaixaEtaria = FaixaEtaria.Quatorze,
            Duracao = new TimeSpan(2, 22, 0),
            Nota = Nota.Cinco,
            Ano = 2012,
            Descricao = "Na região antigamente conhecida como América do Norte, a Capital de Panem controla 12 distritos e os força a escolher um garoto e uma garota, conhecidos como tributos, para competir em um evento anual televisionado. Todos os cidadãos assistem aos temidos jogos, no qual os jovens lutam até a morte, de modo que apenas um saia vitorioso. A jovem Katniss Everdeen, do Distrito 12, confia na habilidade de caça e na destreza com o arco, além dos instintos aguçados, nesta competição mortal.",
        }
    ]
};

app.MapPost("/filmes", (Filme corpo) =>
{
    if (corpo.Id != null)
    {
        return Results.BadRequest(new
        {
            mensagem = "Não informe o id"
        });
    }

    bool possuiFilmeComMesmoNome = banco.Filmes
        .Where(e => string.Equals(e.Titulo, corpo.Titulo, StringComparison.InvariantCultureIgnoreCase))
        .Any();
    if (possuiFilmeComMesmoNome)
    {
        return Results.UnprocessableEntity(new
        {
            mensagem = "Já existe um filme com este nome"
        });
    }

    corpo.Id = Guid.NewGuid();

    banco.Filmes.Add(corpo);

    return Results.Created($"/filmes/{corpo.Id}", corpo);
});

app.MapGet("/filmes", () =>
{
    var filmes = banco.Filmes
        .OrderBy(e => e.Titulo);

    return Results.Ok(filmes);
});

app.MapGet("/filmes/{id}", (Guid id) =>
{
    var filme = banco.Filmes
        .Where(e => e.Id == id)
        .FirstOrDefault();

    return filme != null
        ? Results.Ok(filme)
        : Results.NotFound();
});

app.MapPatch("/filmes/{id}", (Guid id, Filme corpo) =>
{
    if (corpo.Id != null)
    {
        return Results.BadRequest(new
        {
            mensagem = "Não informe o id"
        });
    }

    bool possuiFilmeComMesmoNome = banco.Filmes
        .Where(e => e.Id != id)
        .Where(e => string.Equals(e.Titulo, corpo.Titulo, StringComparison.InvariantCultureIgnoreCase))
        .Any();
    if (possuiFilmeComMesmoNome)
    {
        return Results.UnprocessableEntity(new
        {
            mensagem = "Já existe um filme com este nome"
        });
    }

    int idxFilme = banco.Filmes.FindIndex(e => e.Id == id);
    if (idxFilme == -1)
    {
        return Results.NotFound();
    }

    corpo.Id = banco.Filmes[idxFilme].Id;
    banco.Filmes[idxFilme] = corpo;

    return Results.Ok(corpo);
});

app.MapDelete("/filmes/{id}", (Guid id) =>
{
    if (id == new Guid("7074da12-167a-43ec-ad3f-601ea448b56b"))
    {
        return Results.Json(
            statusCode: (int)HttpStatusCode.Forbidden,
            data: new
            {
                mensagem = "Meu filme não"
            });
    }

    int idxFilme = banco.Filmes.FindIndex(e => e.Id == id);
    if (idxFilme == -1)
    {
        return Results.NotFound();
    }

    banco.Filmes.RemoveAt(idxFilme);

    return Results.NoContent();
});

app.Run();

// Banco de Dados

public class BancoDeDados
{
    public List<Filme> Filmes { get; init; } = [];
}

public class Filme
{
    public Guid? Id { get; set; }
    public required string Titulo { get; init; }
    public required string UrlImagem { get; init; }
    public required string Genero { get; init; }
    public FaixaEtaria FaixaEtaria { get; init; }
    public TimeSpan Duracao { get; init; }
    public Nota Nota { get; init; }
    public int Ano { get; init; }
    public required string Descricao { get; init; }
}

public enum FaixaEtaria
{
    Livre = 0,
    Dez = 10,
    Doze = 12,
    Quatorze = 14,
    Dezesseis = 16,
    Dezoito = 18
}

public enum Nota
{

    Um = 1,
    Dois = 2,
    Tres = 3,
    Quatro = 4,
    Cinco = 5
}
