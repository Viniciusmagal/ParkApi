import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';

class SolicitarVagaScreen extends StatefulWidget {
  const SolicitarVagaScreen({super.key});

  @override
  State<SolicitarVagaScreen> createState() => _SolicitarVagaScreenState();
}

class _SolicitarVagaScreenState extends State<SolicitarVagaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _corController = TextEditingController();
  static final _placaRegex = RegExp(r'^([A-Z]{3}-[0-9]{4}|[A-Z]{3}[0-9][A-Z][0-9]{2})$');
  static const _cores = ['Branco', 'Preto', 'Prata', 'Cinza', 'Vermelho', 'Azul'];

  bool _carregandoCliente = true;
  bool _enviando = false;
  Map<String, dynamic>? _cliente;

  @override
  void initState() {
    super.initState();
    _buscarCliente();
  }

  Future<void> _buscarCliente() async {
    try {
      final data = await ApiService.getJson('/clientes/detalhes');
      _cliente = Map<String, dynamic>.from(data);
    } on ApiException catch (_) {
      _cliente = null;
    }
    if (mounted) setState(() => _carregandoCliente = false);
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final data = await ApiService.postJson('/estacionamentos/solicitar', {
        if (_cliente == null) 'nome': _nomeController.text.trim(),
        if (_cliente == null) 'cpf': _cpfController.text.trim(),
        'placa': _placaController.text.trim().toUpperCase(),
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'cor': _corController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, Ticket.fromJson(Map<String, dynamic>.from(data)));
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  String? _obrigatorio(String? v, String campo) => (v == null || v.trim().isEmpty) ? 'Informe $campo' : null;

  String? _validarCpf(String? v) {
    final cpf = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return 'CPF inválido';
    int digito(int tamanho) {
      var soma = 0;
      for (var i = 0; i < tamanho; i++) {
        soma += int.parse(cpf[i]) * (tamanho + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    if (digito(9) != int.parse(cpf[9]) || digito(10) != int.parse(cpf[10])) return 'CPF inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textStrong,
      ),
      body: _carregandoCliente
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const Text('Solicitar vaga', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textStrong)),
                      const SizedBox(height: 8),
                      const Text(
                        'Preencha os dados abaixo. Uma vaga livre será reservada e você receberá um QR Code.',
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 28),
                      if (_cliente == null) ...[
                        const SectionTitle('Seus dados'),
                        TextFormField(
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          maxLength: 100,
                          decoration: AppColors.input('Nome completo', Icons.person_outline),
                          validator: (v) => _obrigatorio(v, 'seu nome'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: AppColors.input('CPF (somente números)', Icons.badge_outlined),
                          validator: _validarCpf,
                        ),
                        const SizedBox(height: 20),
                      ] else
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${_cliente!['nome']} · CPF ${Fmt.cpfMascarado(_cliente!['cpf'])}',
                                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SectionTitle('Veículo'),
                      TextFormField(
                        controller: _placaController,
                        maxLength: 8,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase())),
                        ],
                        decoration: AppColors.input('Placa (ABC1D23 ou ABC-1234)', Icons.pin_outlined),
                        validator: (v) => _placaRegex.hasMatch((v ?? '').trim().toUpperCase()) ? null : 'Placa inválida',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _marcaController,
                              maxLength: 45,
                              textCapitalization: TextCapitalization.words,
                              decoration: AppColors.input('Marca', Icons.directions_car_outlined),
                              validator: (v) => _obrigatorio(v, 'a marca'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modeloController,
                              maxLength: 45,
                              textCapitalization: TextCapitalization.words,
                              decoration: AppColors.input('Modelo', Icons.car_repair_outlined),
                              validator: (v) => _obrigatorio(v, 'o modelo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _corController,
                        maxLength: 45,
                        textCapitalization: TextCapitalization.words,
                        decoration: AppColors.input('Cor', Icons.palette_outlined),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => _obrigatorio(v, 'a cor'),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cores
                            .map((cor) => ChoiceChip(
                                  label: Text(cor),
                                  selected: _corController.text == cor,
                                  onSelected: (_) => setState(() => _corController.text = cor),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _enviando ? null : _enviar,
                        style: AppColors.primaryButton(),
                        child: _enviando
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Gerar QR Code da vaga'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
