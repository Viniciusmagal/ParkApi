import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/ticket.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/checkout_dialog.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';

class ValidarQrTab extends StatefulWidget {
  const ValidarQrTab({super.key});

  @override
  State<ValidarQrTab> createState() => _ValidarQrTabState();
}

class _ValidarQrTabState extends State<ValidarQrTab> {
  final _manualController = TextEditingController();
  bool _cameraAtiva = false;
  bool _buscando = false;
  Ticket? _ticket;
  String? _ultimoLido;

  Future<void> _consultar(String conteudo) async {
    final recibo = Ticket.reciboDoQr(conteudo);
    if (recibo == null) {
      showMessage(context, 'QR Code ou recibo não reconhecido.', error: true);
      return;
    }
    setState(() {
      _buscando = true;
      _cameraAtiva = false;
    });
    try {
      final data = await ApiService.getJson('/estacionamentos/check-in/$recibo');
      if (!mounted) return;
      setState(() => _ticket = Ticket.fromJson(Map<String, dynamic>.from(data)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _ticket = null);
      showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final valor = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (valor == null || valor == _ultimoLido || _buscando) return;
    _ultimoLido = valor;
    _consultar(valor);
  }

  Future<void> _checkout() async {
    final t = _ticket!;
    final r = await confirmarCheckout(context, recibo: t.recibo, placa: t.placa, vaga: t.vagaCodigo);
    if (r != null && mounted) {
      setState(() {
        _ticket = null;
        _ultimoLido = null;
        _manualController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Validar ticket', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textStrong)),
            const SizedBox(height: 6),
            const Text(
              'Leia o QR Code apresentado pelo motorista ou digite o número do recibo para registrar a saída.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 280,
                color: AppColors.textStrong,
                child: _cameraAtiva
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            onDetect: _onDetect,
                            errorBuilder: (context, error) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Não foi possível acessar a câmera (${error.errorCode.name}). Use a digitação do recibo abaixo.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filled(
                              onPressed: () => setState(() => _cameraAtiva = false),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_scanner, color: Colors.white54, size: 64),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => setState(() {
                                _cameraAtiva = true;
                                _ultimoLido = null;
                              }),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Abrir câmera'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    onSubmitted: _consultar,
                    decoration: AppColors.input('Recibo (ex: 20260927-143012)', Icons.receipt_long_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _buscando ? null : () => _consultar(_manualController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Buscar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_buscando) const Center(child: CircularProgressIndicator()),
            if (_ticket != null && !_buscando) ...[
              TicketCard(ticket: _ticket!, showQr: false, doMotorista: false),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _checkout,
                style: AppColors.primaryButton(),
                icon: const Icon(Icons.logout),
                label: const Text('Registrar saída e cobrar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
