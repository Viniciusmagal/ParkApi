import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/checkout_dialog.dart';
import '../../widgets/common.dart';

class AtivosTab extends StatefulWidget {
  const AtivosTab({super.key});

  @override
  State<AtivosTab> createState() => _AtivosTabState();
}

class _AtivosTabState extends State<AtivosTab> {
  List<Ticket> _ativos = [];
  bool _loading = true;
  String? _erro;
  String _busca = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _carregar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final data = await ApiService.getJson('/estacionamentos/ativos');
      if (!mounted) return;
      setState(() {
        _ativos = List<Map<String, dynamic>>.from(data).map(Ticket.fromJson).toList();
        _erro = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_erro != null) return ErrorState(message: _erro!, onRetry: _carregar);

    final termo = _busca.toLowerCase();
    final lista = _ativos.where((t) {
      return termo.isEmpty ||
          t.placa.toLowerCase().contains(termo) ||
          t.vagaCodigo.toLowerCase().contains(termo) ||
          (t.clienteNome ?? '').toLowerCase().contains(termo);
    }).toList();
    final estimado = _ativos.fold<double>(0, (s, t) => s + t.valorEstimado);

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: StatCard(label: 'Veículos no pátio', value: '${_ativos.length}', icon: Icons.directions_car, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'A receber (estimado)', value: Fmt.moeda(estimado), icon: Icons.payments_outlined, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _busca = v),
            decoration: AppColors.input('Buscar por placa, vaga ou motorista', Icons.search),
          ),
          const SizedBox(height: 16),
          if (lista.isEmpty)
            const EmptyState(icon: Icons.directions_car_outlined, title: 'Pátio vazio', message: 'Nenhum veículo estacionado no momento.'),
          ...lista.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.card(),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                        child: Text(t.vagaCodigo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${t.placa} · ${t.veiculo}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
                            const SizedBox(height: 2),
                            Text(t.clienteNome ?? '-', style: const TextStyle(color: AppColors.text)),
                            Text(
                              'Entrada ${Fmt.hora(t.dataEntrada)} · ${Fmt.duracao(t.permanencia)} · ${Fmt.moeda(t.valorEstimado)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final r = await confirmarCheckout(context, recibo: t.recibo, placa: t.placa, vaga: t.vagaCodigo);
                          if (r != null) _carregar();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Check-out'),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
