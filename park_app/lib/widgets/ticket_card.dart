import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'common.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final bool showQr;
  final bool doMotorista;

  const TicketCard({super.key, required this.ticket, this.showQr = true, this.doMotorista = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doMotorista ? 'SUA VAGA' : 'VAGA', style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(ticket.vagaCodigo, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('PLACA', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Text(ticket.placa, style: const TextStyle(color: AppColors.textStrong, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showQr)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                children: [
                  QrImageView(
                    data: ticket.qrPayload,
                    size: 210,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryDark),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.textStrong),
                  ),
                  const SizedBox(height: 8),
                  const Text('Apresente este QR Code na saída', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                InfoRow('Motorista', ticket.clienteNome ?? '-'),
                InfoRow('Veículo', ticket.veiculo),
                InfoRow('Entrada', Fmt.dataHora(ticket.dataEntrada)),
                if (!ticket.ativo) InfoRow('Saída', Fmt.dataHora(ticket.dataSaida)),
                InfoRow('Permanência', Fmt.duracao(ticket.permanencia)),
                InfoRow('Recibo', ticket.recibo),
                const Divider(height: 24),
                if (ticket.ativo)
                  InfoRow('Valor estimado', Fmt.moeda(ticket.valorEstimado), strong: true)
                else ...[
                  InfoRow('Valor', Fmt.moeda(ticket.valor)),
                  if ((ticket.desconto ?? 0) > 0) InfoRow('Desconto', '- ${Fmt.moeda(ticket.desconto)}'),
                  InfoRow('Total pago', Fmt.moeda(ticket.valorFinal), strong: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabelaPrecos extends StatelessWidget {
  const TabelaPrecos({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.card(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tabela de preços', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textStrong)),
          SizedBox(height: 8),
          InfoRow('Até 15 min', 'R\$ 5,00'),
          InfoRow('Até 1 hora', 'R\$ 9,25'),
          InfoRow('Cada 15 min extra', 'R\$ 1,75'),
          InfoRow('A cada 10 usos', '30% de desconto'),
        ],
      ),
    );
  }
}
