import 'package:flutter/material.dart';
import '../../services/session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../checkin_screen.dart';
import 'ativos_tab.dart';
import 'dashboard_tab.dart';
import 'usuarios_tab.dart';
import 'vagas_tab.dart';
import 'validar_qr_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  int _versao = 0;

  static const _destinos = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.grid_view_outlined, Icons.grid_view, 'Vagas'),
    (Icons.directions_car_outlined, Icons.directions_car, 'No pátio'),
    (Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'Ler QR'),
    (Icons.people_outline, Icons.people, 'Usuários'),
  ];

  void _ir(int index) => setState(() {
        _index = index;
        _versao++;
      });

  Future<void> _checkInManual() async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CheckInScreen()));
    if (ok == true) setState(() => _versao++);
  }

  Widget _conteudo() {
    final key = ValueKey('$_index-$_versao');
    switch (_index) {
      case 0:
        return DashboardTab(key: key, onNavegar: _ir);
      case 1:
        return VagasTab(key: key);
      case 2:
        return AtivosTab(key: key);
      case 3:
        return ValidarQrTab(key: key);
      default:
        return UsuariosTab(key: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: AppColors.textStrong,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.waves, color: AppColors.primary, size: 26),
            const SizedBox(width: 8),
            const Text('ParkAPI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(width: 10),
            const StatusChip(label: 'Admin', color: AppColors.primary, background: AppColors.primarySoft),
            if (largo) ...[
              const SizedBox(width: 16),
              Text(_destinos[_index].$3, style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
            ],
          ],
        ),
        actions: [
          if (largo)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: Text(Session.username ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
            ),
          IconButton(tooltip: 'Check-in manual', icon: const Icon(Icons.add_circle_outline), onPressed: _checkInManual),
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: () => setState(() => _versao++)),
          IconButton(tooltip: 'Sair', icon: const Icon(Icons.logout), onPressed: () => logout(context)),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.border)),
      ),
      body: largo
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _ir,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  destinations: _destinos
                      .map((d) => NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)))
                      .toList(),
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: _conteudo()),
              ],
            )
          : _conteudo(),
      bottomNavigationBar: largo
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _ir,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: _destinos
                  .map((d) => NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3))
                  .toList(),
            ),
    );
  }
}
