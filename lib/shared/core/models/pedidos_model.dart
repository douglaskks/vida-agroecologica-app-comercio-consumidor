class PedidoModel {
  int id;
  String status;
  String tipoEntrega;
  double subtotal;
  double taxaEntrega;
  double total;
  DateTime? dataPedido;
  DateTime? dataConfirmacao;
  DateTime? dataCancelamento;
  DateTime? dataPagamento;
  DateTime? dataEnvio;
  DateTime? dataEntrega;
  int formaPagamentoId;
  int consumidorId;
  int bancaId;
  String? bancaNome;

  PedidoModel({
    required this.id,
    required this.status,
    required this.tipoEntrega,
    required this.subtotal,
    required this.taxaEntrega,
    required this.total,
    this.dataPedido,
    this.dataConfirmacao,
    this.dataCancelamento,
    this.dataPagamento,
    this.dataEnvio,
    this.dataEntrega,
    required this.formaPagamentoId,
    required this.consumidorId,
    required this.bancaId,
    this.bancaNome,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      id: json['id'],
      status: json['status'],
      tipoEntrega: json['tipo_entrega'],
      subtotal: double.parse(json['subtotal'].toString()),
      taxaEntrega: double.parse(json['taxa_entrega'].toString()),
      total: double.parse(json['total'].toString()),
      dataPedido: json['data_pedido'] != null
          ? DateTime.parse(json['data_pedido'])
          : null,
      dataConfirmacao: json['data_confirmacao'] != null
          ? DateTime.parse(json['data_confirmacao'])
          : null,
      dataCancelamento: json['data_cancelamento'] != null
          ? DateTime.parse(json['data_cancelamento'])
          : null,
      dataPagamento: json['data_pagamento'] != null
          ? DateTime.parse(json['data_pagamento'])
          : null,
      dataEnvio: json['data_envio'] != null
          ? DateTime.parse(json['data_envio'])
          : null,
      dataEntrega: json['data_entrega'] != null
          ? DateTime.parse(json['data_entrega'])
          : null,
      formaPagamentoId: json['forma_pagamento_id'],
      consumidorId: json['consumidor_id'],
      bancaId: json['banca_id'],
      bancaNome: json['banca_nome'],
    );
  }
}
