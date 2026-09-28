import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';

class MinhaVagaTab extends StatefulWidget {
  final Ticket? ativo;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onSolicitar;

  const MinhaVagaTab({super.key, required this.ativo, required this.loading, required this.onRefresh, required this.onSolicitar});

  @override
  State<MinhaVagaTab> createState() => _MinhaVagaTabState();
}

class _MinhaVagaTabState extends State<MinhaVagaTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && widget.ativo != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ativo;
    if (ticket == null) {
      if (widget.loading) return const Center(child: CircularProgressIndicator());
      return EmptyState(
        icon: Icons.local_parking,
        title: 'Nenhuma vaga ativa',
        message: 'Quando você solicitar uma vaga, o ticket com QR Code aparecerá aqui.',
        action: SizedBox(
          width: 240,
          child: ElevatedButton.icon(
            onPressed: widget.onSolicitar,
            style: AppColors.primaryButton(),
            icon: const Icon(Icons.add),
            label: const Text('Solicitar vaga'),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Vaga reservada e veículo em permanência', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TicketCard(ticket: ticket),
          const SizedBox(height: 16),
          const Text(
            'O valor estimado é atualizado automaticamente. O valor final é calculado no momento da saída.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar status'),
          ),
        ],
      ),
    );
  }
}
