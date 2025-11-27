class BancaModel {
  int id;
  String nome;
  String? descricao;
  String? horarioAbertura; // ← Agora nullable
  String? horarioFechamento; // ← Agora nullable
  bool entrega;
  double precoMinimo;
  int feiraId;
  int agricultorId;
  String? pix;
  Map<String, dynamic>? horariosFuncionamento; // ← Adicionar o campo real da API

  BancaModel({
    required this.id,
    required this.nome,
    this.descricao,
    this.horarioAbertura,
    this.horarioFechamento,
    required this.entrega,
    required this.precoMinimo,
    required this.feiraId,
    required this.agricultorId,
    this.pix,
    this.horariosFuncionamento,
  });

  factory BancaModel.fromJson(Map<String, dynamic> json) {
    return BancaModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      horarioAbertura: json['horario_abertura'] as String?, // ← Nullable
      horarioFechamento: json['horario_fechamento'] as String?, // ← Nullable
      entrega: json['entrega'] as bool? ?? false, // ← Valor padrão
      precoMinimo: json['preco_minimo'] != null 
          ? double.parse(json['preco_minimo'].toString()) 
          : 0.0, // ← Proteção
      feiraId: json['feira_id'] as int,
      agricultorId: json['agricultor_id'] as int,
      pix: json['pix'] as String?,
      horariosFuncionamento: json['horarios_funcionamento'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['descricao'] = descricao;
    data['horario_abertura'] = horarioAbertura;
    data['horario_fechamento'] = horarioFechamento;
    data['entrega'] = entrega;
    data['preco_minimo'] = precoMinimo.toString();
    data['feira_id'] = feiraId;
    data['agricultor_id'] = agricultorId;
    data['pix'] = pix;
    data['horarios_funcionamento'] = horariosFuncionamento;
    return data;
  }
}