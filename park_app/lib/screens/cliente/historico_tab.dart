import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';
import '../relatorio_screen.dart';

class HistoricoTab extends StatefulWidget {
  const HistoricoTab({super.key});

  @override
  State<HistoricoTab> createState() => _HistoricoTabState();
}

class _HistoricoTabState extends State<HistoricoTab> {
  late Future<List<Ticket>> _future = _carregar();

  Future<List<Ticket>> _carregar() async {
    final data = await ApiService.getJson('/estacionamentos?size=50&sort=dataEntrada,desc');
    final content = (data['content'] as List? ?? []);
    return content.map((e) => Ticket.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _carregar());
    await _future.catchError((_) => <Ticket>[]);
  }

  void _detalhes(Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: TicketCard(ticket: ticket, showQr: ticket.ativo)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(message: snapshot.error.toString(), onRetry: _refresh);
        }
        final tickets = snapshot.data!;
        if (tickets.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'Sem histórico',
            message: 'Seus estacionamentos aparecerão aqui.',
          );
        }
        final totalGasto = tickets.where((t) => !t.ativo).fold<double>(0, (s, t) => s + t.valorFinal);
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Visitas', value: '${tickets.length}', icon: Icons.local_parking, color: AppColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard(label: 'Total pago', value: Fmt.moeda(totalGasto), icon: Icons.payments_outlined, color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatorioScreen())),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Meu relatório em PDF'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    ),
                  ],
                );
              }
              final t = tickets[i - 1];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _detalhes(t),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12)),
                          child: Text(t.vagaCodigo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${t.placa} · ${t.modelo}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                              const SizedBox(height: 2),
                              Text(
                                '${Fmt.dataHora(t.dataEntrada)}${t.ativo ? '' : ' → ${Fmt.hora(t.dataSaida)}'}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        t.ativo
                            ? const StatusChip(label: 'Em andamento', color: AppColors.primary, background: AppColors.primarySoft)
                            : Text(Fmt.moeda(t.valorFinal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textStrong)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
