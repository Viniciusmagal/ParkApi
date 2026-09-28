import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import 'historico_tab.dart';
import 'inicio_tab.dart';
import 'minha_vaga_tab.dart';
import 'solicitar_vaga_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _index = 0;
  bool _loading = true;
  String? _erro;
  Ticket? _ativo;
  int _livres = 0;
  int _ocupadas = 0;
  int _historicoVersao = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final disponibilidade = await ApiService.getJson('/vagas/disponibilidade');
      final ativo = await ApiService.getJson('/estacionamentos/ativo');
      if (!mounted) return;
      final saiu = _ativo != null && ativo == null;
      setState(() {
        _livres = (disponibilidade['livres'] as num).toInt();
        _ocupadas = (disponibilidade['ocupadas'] as num).toInt();
        _ativo = ativo == null ? null : Ticket.fromJson(Map<String, dynamic>.from(ativo));
        if (saiu) _historicoVersao++;
      });
      if (saiu) showMessage(context, 'Sua saída foi registrada. Obrigado pela visita!');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.status == 401) {
        await logout(context);
        return;
      }
      setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _solicitar() async {
    if (_ativo != null) {
      setState(() => _index = 1);
      return;
    }
    final ticket = await Navigator.push<Ticket>(
      context,
      MaterialPageRoute(builder: (_) => const SolicitarVagaScreen()),
    );
    if (ticket == null || !mounted) return;
    setState(() {
      _ativo = ticket;
      _index = 1;
      _historicoVersao++;
    });
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      InicioTab(
        livres: _livres,
        ocupadas: _ocupadas,
        ativo: _ativo,
        loading: _loading,
        erro: _erro,
        onSolicitar: _solicitar,
        onVerTicket: () => setState(() => _index = 1),
        onRefresh: _carregar,
      ),
      MinhaVagaTab(ativo: _ativo, loading: _loading, onRefresh: _carregar, onSolicitar: _solicitar),
      HistoricoTab(key: ValueKey(_historicoVersao)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Olá, motorista!', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(Session.username ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: _carregar),
          IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: IndexedStack(index: _index, children: tabs),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(
            icon: Badge(isLabelVisible: _ativo != null, child: const Icon(Icons.qr_code_2_outlined)),
            selectedIcon: const Icon(Icons.qr_code_2),
            label: 'Minha vaga',
          ),
          const NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }
}
