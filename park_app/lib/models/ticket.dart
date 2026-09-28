import 'dart:convert';
import '../utils/formatters.dart';

class Ticket {
  final String recibo;
  final String placa;
  final String marca;
  final String modelo;
  final String cor;
  final String vagaCodigo;
  final String? clienteNome;
  final String? clienteCpf;
  final DateTime dataEntrada;
  final DateTime? dataSaida;
  final double? valor;
  final double? desconto;

  Ticket({
    required this.recibo,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.cor,
    required this.vagaCodigo,
    required this.dataEntrada,
    this.clienteNome,
    this.clienteCpf,
    this.dataSaida,
    this.valor,
    this.desconto,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      recibo: json['recibo'] ?? '',
      placa: json['placa'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      cor: json['cor'] ?? '',
      vagaCodigo: json['vagaCodigo'] ?? '-',
      clienteNome: json['clienteNome'],
      clienteCpf: json['clienteCpf'],
      dataEntrada: Fmt.parseData(json['dataEntrada']) ?? DateTime.now(),
      dataSaida: Fmt.parseData(json['dataSaida']),
      valor: (json['valor'] as num?)?.toDouble(),
      desconto: (json['desconto'] as num?)?.toDouble(),
    );
  }

  bool get ativo => dataSaida == null;

  String get veiculo => '$marca $modelo · $cor';

  Duration get permanencia => (dataSaida ?? DateTime.now()).difference(dataEntrada);

  double get valorEstimado => calcularCusto(permanencia.inMinutes);

  double get valorFinal => (valor ?? 0) - (desconto ?? 0);

  String get qrPayload => jsonEncode({
        'app': 'ParkAPI',
        'recibo': recibo,
        'vaga': vagaCodigo,
        'placa': placa,
        'nome': clienteNome ?? '',
        'cpf': Fmt.cpfMascarado(clienteCpf),
        'entrada': Fmt.dataHora(dataEntrada),
      });

  static double calcularCusto(int minutos) {
    if (minutos <= 15) return 5.00;
    if (minutos <= 60) return 9.25;
    final adicionais = ((minutos - 60) / 15).ceil();
    return 9.25 + 1.75 * adicionais;
  }

  static String? reciboDoQr(String conteudo) {
    final texto = conteudo.trim();
    try {
      final data = jsonDecode(texto);
      if (data is Map && data['recibo'] is String) return data['recibo'];
    } catch (_) {}
    final match = RegExp(r'\d{8}-\d{6}').firstMatch(texto);
    return match?.group(0);
  }
}
