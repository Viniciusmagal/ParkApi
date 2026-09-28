import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/checkout_dialog.dart';
import '../../widgets/common.dart';

class VagasTab extends StatefulWidget {
  const VagasTab({super.key});

  @override
  State<VagasTab> createState() => _VagasTabState();
}

class _VagasTabState extends State<VagasTab> {
  List<Map<String, dynamic>> _vagas = [];
  Map<String, Ticket> _ocupacao = {};
  bool _loading = true;
  String? _erro;
  String _filtro = 'TODAS';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final vagas = await ApiService.getJson('/vagas');
      final ativos = await ApiService.getJson('/estacionamentos/ativos');
      if (!mounted) return;
      setState(() {
        _vagas = List<Map<String, dynamic>>.from(vagas);
        _ocupacao = {
          for (final a in List<Map<String, dynamic>>.from(ativos)) a['vagaCodigo'] as String: Ticket.fromJson(a),
        };
        _erro = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _novaVaga() async {
    final controller = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova vaga'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 4,
          textCapitalization: TextCapitalization.characters,
          decoration: AppColors.input('Código (ex: C-01)', Icons.local_parking),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim().toUpperCase()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
    if (codigo == null || codigo.isEmpty || !mounted) return;
    if (codigo.length != 4) {
      showMessage(context, 'O código deve ter exatamente 4 caracteres.', error: true);
      return;
    }
    try {
      await ApiService.postJson('/vagas', {'codigo': codigo, 'status': 'LIVRE'});
      if (!mounted) return;
      showMessage(context, 'Vaga $codigo cadastrada.');
      _carregar();
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    }
  }

  void _detalhes(String codigo) {
    final t = _ocupacao[codigo];
    if (t == null) {
      showMessage(context, 'Vaga $codigo está livre.');
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vaga $codigo', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InfoRow('Motorista', t.clienteNome ?? '-'),
            InfoRow('CPF', Fmt.cpf(t.clienteCpf)),
            InfoRow('Placa', t.placa),
            InfoRow('Veículo', t.veiculo),
            InfoRow('Entrada', Fmt.dataHora(t.dataEntrada)),
            InfoRow('Permanência', Fmt.duracao(t.permanencia)),
            InfoRow('Valor estimado', Fmt.moeda(t.valorEstimado), strong: true),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: AppColors.primaryButton(),
              icon: const Icon(Icons.logout),
              label: const Text('Registrar saída'),
              onPressed: () async {
                Navigator.pop(sheet);
                final r = await confirmarCheckout(context, recibo: t.recibo, placa: t.placa, vaga: codigo);
                if (r != null) _carregar();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_erro != null) return ErrorState(message: _erro!, onRetry: _carregar);

    final livres = _vagas.where((v) => v['status'] == 'LIVRE').length;
    final visiveis = _vagas.where((v) => _filtro == 'TODAS' || v['status'] == _filtro).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaVaga,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova vaga'),
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _filtroChip('TODAS', 'Todas (${_vagas.length})'),
                _filtroChip('LIVRE', 'Livres ($livres)'),
                _filtroChip('OCUPADA', 'Ocupadas (${_vagas.length - livres})'),
              ],
            ),
            const SizedBox(height: 16),
            GridView.extent(
              maxCrossAxisExtent: 180,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: visiveis.map(_vagaTile).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroChip(String valor, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _filtro == valor,
      onSelected: (_) => setState(() => _filtro = valor),
    );
  }

  Widget _vagaTile(Map<String, dynamic> vaga) {
    final codigo = vaga['codigo'] as String;
    final livre = vaga['status'] == 'LIVRE';
    final t = _ocupacao[codigo];
    final cor = livre ? AppColors.success : AppColors.danger;
    return InkWell(
      onTap: () => _detalhes(codigo),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: livre ? Colors.white : AppColors.dangerSoft.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(codigo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textStrong))),
                Icon(livre ? Icons.local_parking : Icons.directions_car, color: cor),
              ],
            ),
            const Spacer(),
            livre ? StatusChip.livre() : StatusChip.ocupada(),
            if (t != null) ...[
              const SizedBox(height: 6),
              Text(t.placa, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
              Text(t.clienteNome ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ] else if (!livre)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Sem ticket vinculado', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ),
          ],
        ),
      ),
    );
  }
}
