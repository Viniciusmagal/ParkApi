import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';

class UsuariosTab extends StatefulWidget {
  const UsuariosTab({super.key});

  @override
  State<UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<UsuariosTab> {
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _clientes = [];
  bool _loading = true;
  String? _erro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final usuarios = await ApiService.getJson('/usuarios');
      final clientes = await ApiService.getJson('/clientes?size=200&sort=nome,asc');
      if (!mounted) return;
      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(usuarios);
        _clientes = List<Map<String, dynamic>>.from(clientes['content'] ?? []);
        _erro = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _combina(String texto) => _busca.isEmpty || texto.toLowerCase().contains(_busca.toLowerCase());

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_erro != null) return ErrorState(message: _erro!, onRetry: _carregar);

    final usuarios = _usuarios.where((u) => _combina('${u['username']} ${u['role']}')).toList();
    final clientes = _clientes.where((c) => _combina('${c['nome']} ${c['cpf']}')).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _busca = v),
              decoration: AppColors.input('Buscar por e-mail, nome ou CPF', Icons.search),
            ),
          ),
          TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Usuários (${_usuarios.length})'),
              Tab(text: 'Clientes (${_clientes.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _lista(
                  usuarios.map((u) {
                    final admin = u['role'] == 'ADMIN';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: admin ? AppColors.primarySoft : AppColors.inputFill,
                        child: Icon(admin ? Icons.admin_panel_settings : Icons.person, color: admin ? AppColors.primary : AppColors.textMuted),
                      ),
                      title: Text(u['username'] ?? ''),
                      subtitle: Text('ID ${u['id']}'),
                      trailing: admin
                          ? const StatusChip(label: 'Administrador', color: AppColors.primary, background: AppColors.primarySoft)
                          : const StatusChip(label: 'Cliente', color: AppColors.textMuted, background: AppColors.inputFill),
                    );
                  }).toList(),
                ),
                _lista(
                  clientes.map((c) {
                    final nome = (c['nome'] ?? '') as String;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Text(nome.isEmpty ? '?' : nome[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(nome),
                      subtitle: Text('CPF ${Fmt.cpf(c['cpf'])}'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(List<Widget> itens) {
    if (itens.isEmpty) {
      return const EmptyState(icon: Icons.person_search, title: 'Nada encontrado', message: 'Nenhum registro para exibir.');
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: itens.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, i) => itens[i],
      ),
    );
  }
}
