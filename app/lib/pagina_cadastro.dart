import 'dart:convert';
import 'dart:developer';

import 'package:app/filme_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaginaCadastro extends StatefulWidget {
  const PaginaCadastro({super.key, this.idFilme});

  final String? idFilme;

  @override
  State<PaginaCadastro> createState() => _PaginaCadastroState();
}

class _PaginaCadastroState extends State<PaginaCadastro> {
  FilmeModel? filme;

  bool isLoading = false;

  late var urlImagem = TextEditingController();
  late var titulo = TextEditingController();
  late var genero = TextEditingController();
  // faixa etaria
  late var duracao = TextEditingController();
  // nota
  late var ano = TextEditingController();
  late var descricao = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.idFilme != null) {
      preencherDados(widget.idFilme!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading
              ? 'Carregando aguarde...'
              : filme != null
              ? 'Editar Filme ${filme!.titulo}'
              : 'Cadastrar Filme',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: salvar,
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: urlImagem,
              decoration: InputDecoration(labelText: 'Url Imagem'),
            ),
            TextFormField(
              controller: titulo,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextFormField(
              controller: genero,
              decoration: InputDecoration(labelText: 'Gênero'),
            ),
            TextFormField(
              controller: duracao,
              decoration: InputDecoration(labelText: 'Duração'),
            ),
            TextFormField(
              controller: ano,
              decoration: InputDecoration(labelText: 'Ano'),
            ),
            TextFormField(
              controller: descricao,
              decoration: InputDecoration(labelText: 'Descição'),
            ),
          ],
        ),
      ),
    );
  }

  Future salvar() async {
    var navigator = Navigator.of(context);
    var messenger = ScaffoldMessenger.of(context);
    if (duracao.text.length != 8) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Digite uma duração válida (no formato HH:mm:ss)'),
        ),
      );
    }

    int? anoParseado = int.tryParse(ano.text);
    if (anoParseado == null || anoParseado < 1930 || anoParseado > 2025) {
      messenger.showSnackBar(SnackBar(content: Text('Digite um ano válido')));
    }

    var corpo = FilmeModel(
      titulo: titulo.text,
      urlImagem: urlImagem.text,
      genero: genero.text,
      faixaEtaria: 0, // TODO:
      duracao: duracao.text,
      nota: 4,
      ano: int.parse(ano.text),
      descricao: descricao.text,
    );

    http.Response response;
    try {
      if (filme != null) {
        response = await http.patch(
          Uri.parse('http://localhost:5062/filmes/${filme!.id}'),
          body: jsonEncode(corpo.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        response = await http.post(
          Uri.parse('http://localhost:5062/filmes'),
          body: jsonEncode(corpo.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print('$e');
      return;
    }

    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      navigator.pop();
    } else {
      throw body['mensagem'] ?? "Erro inesperado";
    }
  }

  Future preencherDados(String id) async {
    FilmeModel? filmeCarregado = await carregarFilme(id);
    setState(() => filme = filmeCarregado);
    if (filmeCarregado == null) return;

    urlImagem.value = TextEditingValue(text: filmeCarregado.urlImagem);
    titulo.value = TextEditingValue(text: filmeCarregado.titulo);
    genero.value = TextEditingValue(text: filmeCarregado.genero);
    duracao.value = TextEditingValue(text: filmeCarregado.duracao);
    ano.value = TextEditingValue(text: filmeCarregado.ano.toString());
    descricao.value = TextEditingValue(text: filmeCarregado.descricao);
  }

  Future<FilmeModel?> carregarFilme(String id) async {
    try {
      setState(() => isLoading = true);

      var response = await http.get(
        Uri.parse('http://localhost:5062/filmes/$id'),
      );
      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        FilmeModel? filmeObtido = FilmeModel.fromJson(body);
        return filmeObtido;
      } else {
        throw body['mensagem'] ?? "Erro inesperado";
      }
    } catch (e) {
      log('$e');
    } finally {
      setState(() => isLoading = false);
    }

    return null;
  }
}
