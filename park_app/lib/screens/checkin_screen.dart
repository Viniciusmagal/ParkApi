import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _corController = TextEditingController();
  final _cpfController = TextEditingController();

  Future<void> _realizarCheckIn() async {
    final response = await ApiService.post('/estacionamentos/check-in', {
      'placa': _placaController.text,
      'marca': _marcaController.text,
      'modelo': _modeloController.text,
      'cor': _corController.text,
      'clienteCpf': _cpfController.text,
    });

    if (!mounted) return;
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in realizado com sucesso!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao realizar Check-in.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _placaController, decoration: const InputDecoration(labelText: 'Placa')),
            TextField(controller: _marcaController, decoration: const InputDecoration(labelText: 'Marca')),
            TextField(controller: _modeloController, decoration: const InputDecoration(labelText: 'Modelo')),
            TextField(controller: _corController, decoration: const InputDecoration(labelText: 'Cor')),
            TextField(controller: _cpfController, decoration: const InputDecoration(labelText: 'CPF do Cliente')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _realizarCheckIn,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              child: const Text('Confirmar Check-in', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}