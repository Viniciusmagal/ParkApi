import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';

class DashboardTab extends StatefulWidget {
  final void Function(int) onNavegar;

  const DashboardTab({super.key, required this.onNavegar});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Map<String, dynamic>? _data;
  String? _erro;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _carregar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final data = await ApiService.getJson('/dashboard');
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(data);
          _erro = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      if (_erro != null) return ErrorState(message: _erro!, onRetry: _carregar);
      return const Center(child: CircularProgressIndicator());
    }
    final d = _data!;
    num n(String k) => (d[k] as num?) ?? 0;
    final largura = MediaQuery.of(context).size.width;
    final colunas = largura >= 1200 ? 4 : (largura >= 700 ? 3 : 2);

    final cards = [
      StatCard(label: 'Vagas livres', value: '${n('vagasLivres')}', hint: 'de ${n('totalVagas')} vagas', icon: Icons.check_circle_outline, color: AppColors.success),
      StatCard(label: 'Vagas ocupadas', value: '${n('vagasOcupadas')}', icon: Icons.block, color: AppColors.danger),
      StatCard(label: 'Entradas hoje', value: '${n('entradasHoje')}', icon: Icons.login, color: AppColors.primary),
      StatCard(label: 'Saídas hoje', value: '${n('saidasHoje')}', icon: Icons.logout, color: AppColors.warning),
      StatCard(label: 'Faturamento hoje', value: Fmt.moeda(n('faturamentoHoje')), icon: Icons.payments_outlined, color: AppColors.success),
      StatCard(label: 'Faturamento total', value: Fmt.moeda(n('faturamentoTotal')), icon: Icons.account_balance_wallet_outlined, color: AppColors.primaryDark),
      StatCard(label: 'Usuários', value: '${n('totalUsuarios')}', hint: '${n('totalAdministradores')} administrador(es)', icon: Icons.people_outline, color: AppColors.primary),
      StatCard(label: 'Clientes', value: '${n('totalClientes')}', icon: Icons.badge_outlined, color: AppColors.textMuted),
    ];

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ocupacao(n('taxaOcupacao').toDouble(), n('vagasOcupadas').toInt(), n('totalVagas').toInt(), n('veiculosNoPatio').toInt()),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: colunas,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: colunas == 2 ? 1.9 : (colunas == 3 ? 2.8 : 3.4),
            children: cards,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            final grafico = _grafico(List<Map<String, dynamic>>.from(d['entradasUltimos7Dias'] ?? []));
            final movimentos = _movimentacoes(List<Map<String, dynamic>>.from(d['ultimasMovimentacoes'] ?? []));
            if (c.maxWidth < 900) {
              return Column(children: [grafico, const SizedBox(height: 16), movimentos]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: grafico),
                const SizedBox(width: 16),
                Expanded(child: movimentos),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _ocupacao(double taxa, int ocupadas, int total, int noPatio) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Ocupação do estacionamento', style: TextStyle(color: Colors.white70))),
              TextButton.icon(
                onPressed: () => widget.onNavegar(1),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.grid_view, size: 18),
                label: const Text('Ver mapa'),
              ),
            ],
          ),
          Text('${taxa.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : ocupadas / total,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text('$ocupadas de $total vagas ocupadas · $noPatio veículo(s) no pátio', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _grafico(List<Map<String, dynamic>> dias) {
    final maximo = dias.fold<num>(0, (m, e) => (e['entradas'] as num) > m ? e['entradas'] as num : m);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Entradas nos últimos 7 dias'),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dias.map((e) {
                final valor = (e['entradas'] as num).toInt();
                final dia = DateTime.parse(e['dia']);
                final hoje = dia.day == DateTime.now().day;
                final altura = maximo == 0 ? 0.0 : 120 * valor / maximo;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$valor', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
                        const SizedBox(height: 4),
                        Container(
                          height: altura < 4 ? 4 : altura,
                          decoration: BoxDecoration(
                            color: hoje ? AppColors.primary : AppColors.primary.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(Fmt.diaSemana(dia), style: TextStyle(fontSize: 12, color: hoje ? AppColors.primary : AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movimentacoes(List<Map<String, dynamic>> itens) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Últimas movimentações', trailing: TextButton(onPressed: () => widget.onNavegar(2), child: const Text('Ver pátio'))),
          if (itens.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nenhuma movimentação ainda.', style: TextStyle(color: AppColors.textMuted))),
            ),
          ...itens.map((e) {
            final t = Ticket.fromJson(e);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: t.ativo ? AppColors.primarySoft : AppColors.inputFill,
                child: Icon(t.ativo ? Icons.login : Icons.logout, color: t.ativo ? AppColors.primary : AppColors.textMuted, size: 20),
              ),
              title: Text('${t.placa} · vaga ${t.vagaCodigo}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(t.clienteNome ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.hora(t.ativo ? t.dataEntrada : t.dataSaida), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  t.ativo
                      ? const Text('Entrada', style: TextStyle(color: AppColors.primary, fontSize: 12))
                      : Text(Fmt.moeda(t.valorFinal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
