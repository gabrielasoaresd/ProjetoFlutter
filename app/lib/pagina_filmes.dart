import 'dart:convert';
import 'dart:developer';

import 'package:app/filme_model.dart';
import 'package:app/smooth_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaginaFilmes extends StatefulWidget {
  const PaginaFilmes({super.key});

  @override
  State<PaginaFilmes> createState() => _PaginaFilmesState();
}

class _PaginaFilmesState extends State<PaginaFilmes> {
  bool isLoading = false;
  List<FilmeModel>? filmes;

  @override
  void initState() {
    super.initState();

    carregarFilmes();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Filmes"),
        actions: [
          IconButton(
            onPressed:
                () => {
                  // TODO: abrir janelas que apresenta criadores do projeto
                },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => {
              // TODO: navegar tela adicionar filme
            },
        tooltip: 'Adicionar filme',
        child: const Icon(Icons.add),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!isLoading && filmes == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text('Falha ao carregar os filmes')),
            ),
          if (!isLoading && filmes != null)
            ...filmes?.map(
                  (e) => Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.all(8),
                    child: SizedBox(
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.network(e.urlImagem, height: double.infinity),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 260),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.titulo),
                                      Tooltip(
                                        message: e.descricao,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            e.descricao,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Text(e.duracao),
                                    ],
                                  ),
                                ),
                                SmoothStarRating(rating: e.nota.toDouble()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) ??
                [],
        ],
      ),
    );
  }

  Future carregarFilmes() async {
    try {
      setState(() => isLoading = true);

      await Future.delayed(Durations.extralong4);

      var response = await http.get(Uri.parse('http://localhost:5062/filmes'));
      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<FilmeModel> filmesObtidos =
            (body as List<dynamic>).map((e) => FilmeModel.fromJson(e)).toList();

        setState(() => filmes = filmesObtidos);
      } else {
        if (body?.mensagem != null) {
          throw body.mensagem;
        } else {
          throw "Erro inesperado";
        }
      }
    } catch (e) {
      log('$e');
    } finally {
      setState(() => isLoading = false);
    }
  }
}
