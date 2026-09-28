import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_app/models/ticket.dart';

void main() {
  test('calcula o custo igual à tabela da API', () {
    expect(Ticket.calcularCusto(10), 5.00);
    expect(Ticket.calcularCusto(60), 9.25);
    expect(Ticket.calcularCusto(61), 11.00);
    expect(Ticket.calcularCusto(90), 12.75);
  });

  test('QR Code carrega o recibo e mascara o CPF', () {
    final ticket = Ticket.fromJson({
      'recibo': '20260927-143012',
      'placa': 'ABC1D23',
      'marca': 'Fiat',
      'modelo': 'Uno',
      'cor': 'Prata',
      'vagaCodigo': 'A-03',
      'clienteNome': 'Maria',
      'clienteCpf': '52998224725',
      'dataEntrada': '2026-09-27 14:30:12',
    });
    final payload = jsonDecode(ticket.qrPayload) as Map<String, dynamic>;
    expect(payload['recibo'], '20260927-143012');
    expect(payload['vaga'], 'A-03');
    expect(payload['cpf'], '***.982.247-**');
    expect(Ticket.reciboDoQr(ticket.qrPayload), '20260927-143012');
    expect(Ticket.reciboDoQr(' 20260927-143012 '), '20260927-143012');
    expect(Ticket.reciboDoQr('qualquer coisa'), isNull);
  });
}
