import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _corController = TextEditingController();
  final _cpfController = TextEditingController();
  bool _isLoading = false;

  Future<void> _realizarCheckIn() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.postJson('/estacionamentos/check-in', {
        'placa': _placaController.text.trim().toUpperCase(),
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'cor': _corController.text.trim(),
        'clienteCpf': _cpfController.text.trim(),
      });
      if (!mounted) return;
      showMessage(context, 'Check-in realizado na vaga ${data['vagaCodigo']}.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in manual')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Use para registrar a entrada de um cliente já cadastrado que não solicitou a vaga pelo app.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: AppColors.input('CPF do cliente (somente números)', Icons.badge_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _placaController,
                maxLength: 8,
                textCapitalization: TextCapitalization.characters,
                decoration: AppColors.input('Placa (ABC-1234)', Icons.pin_outlined),
              ),
              const SizedBox(height: 12),
              TextField(controller: _marcaController, decoration: AppColors.input('Marca', Icons.directions_car_outlined)),
              const SizedBox(height: 12),
              TextField(controller: _modeloController, decoration: AppColors.input('Modelo', Icons.car_repair_outlined)),
              const SizedBox(height: 12),
              TextField(controller: _corController, decoration: AppColors.input('Cor', Icons.palette_outlined)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _realizarCheckIn,
                style: AppColors.primaryButton(),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirmar check-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
