class FilmeModel {
  FilmeModel({
    this.id,
    required this.titulo,
    required this.urlImagem,
    required this.genero,
    required this.faixaEtaria,
    required this.duracao,
    required this.nota,
    required this.ano,
    required this.descricao,
  });

  FilmeModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      titulo = json['titulo'],
      urlImagem = json['urlImagem'],
      genero = json['genero'],
      faixaEtaria = json['faixaEtaria'],
      duracao = json['duracao'],
      nota = json['nota'],
      ano = json['ano'],
      descricao = json['descricao'];

  String? id;
  String titulo;
  String urlImagem;
  String genero;
  int faixaEtaria;
  String duracao;
  int nota;
  int ano;
  String descricao;
}
