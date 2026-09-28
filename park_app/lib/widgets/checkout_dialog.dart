import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'common.dart';

Future<Ticket?> confirmarCheckout(BuildContext context, {required String recibo, required String placa, required String vaga}) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar saída'),
      content: Text('Registrar a saída do veículo $placa da vaga $vaga?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: const Text('Confirmar check-out'),
        ),
      ],
    ),
  );
  if (confirmar != true || !context.mounted) return null;

  try {
    final data = await ApiService.putJson('/estacionamentos/check-out/$recibo');
    final ticket = Ticket.fromJson(Map<String, dynamic>.from(data));
    if (!context.mounted) return ticket;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Saída registrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoRow('Placa', ticket.placa),
            InfoRow('Vaga liberada', ticket.vagaCodigo),
            InfoRow('Permanência', Fmt.duracao(ticket.permanencia)),
            InfoRow('Valor', Fmt.moeda(ticket.valor)),
            if ((ticket.desconto ?? 0) > 0) InfoRow('Desconto', '- ${Fmt.moeda(ticket.desconto)}'),
            const Divider(),
            InfoRow('Total a cobrar', Fmt.moeda(ticket.valorFinal), strong: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
    return ticket;
  } on ApiException catch (e) {
    if (context.mounted) showMessage(context, e.message, error: true);
    return null;
  }
}
