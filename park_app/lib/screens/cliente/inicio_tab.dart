import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';

class InicioTab extends StatelessWidget {
  final int livres;
  final int ocupadas;
  final Ticket? ativo;
  final bool loading;
  final String? erro;
  final VoidCallback onSolicitar;
  final VoidCallback onVerTicket;
  final Future<void> Function() onRefresh;

  const InicioTab({
    super.key,
    required this.livres,
    required this.ocupadas,
    required this.ativo,
    required this.loading,
    required this.erro,
    required this.onSolicitar,
    required this.onVerTicket,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (erro != null && !loading) {
      return ErrorState(message: erro!, onRetry: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: loading && livres + ocupadas == 0
                ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: Colors.white)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _contador('$livres', 'vagas livres'),
                      _contador('$ocupadas', 'ocupadas'),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          if (ativo != null) _cardAtivo() else _cardSolicitar(),
          const SizedBox(height: 24),
          const SectionTitle('Como funciona'),
          _passo(Icons.edit_note, 'Solicite a vaga', 'Informe seus dados e os do veículo.'),
          _passo(Icons.qr_code_2, 'Receba o QR Code', 'Uma vaga livre é reservada na hora para você.'),
          _passo(Icons.logout, 'Apresente na saída', 'O atendente lê o QR Code e calcula o valor.'),
          const SizedBox(height: 16),
          const TabelaPrecos(),
        ],
      ),
    );
  }

  Widget _contador(String valor, String label) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _cardSolicitar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chegou ao estacionamento?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textStrong)),
          const SizedBox(height: 6),
          Text(
            livres > 0 ? 'Solicite sua vaga em poucos segundos.' : 'No momento não há vagas livres.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: livres > 0 ? onSolicitar : null,
            style: AppColors.primaryButton(),
            icon: const Icon(Icons.local_parking),
            label: const Text('Solicitar vaga'),
          ),
        ],
      ),
    );
  }

  Widget _cardAtivo() {
    final ticket = ativo!;
    return InkWell(
      onTap: onVerTicket,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppColors.card(),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: Text(ticket.vagaCodigo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Você está estacionado', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textStrong)),
                  const SizedBox(height: 4),
                  Text('${ticket.placa} · desde ${Fmt.hora(ticket.dataEntrada)}', style: const TextStyle(color: AppColors.textMuted)),
                  Text('Estimado: ${Fmt.moeda(ticket.valorEstimado)}', style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.qr_code_2, color: AppColors.primary, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _passo(IconData icon, String titulo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primarySoft, child: Icon(icon, color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                Text(texto, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
