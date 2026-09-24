import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../services/api_service.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = ApiService.getRelatorioPdf();
  }

  void _tentarNovamente() {
    setState(() => _pdfFuture = ApiService.getRelatorioPdf());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu relatório')),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error!;
            final message = error is TimeoutException
                ? 'A API demorou para responder. Tente novamente.'
                : error is Exception && error.toString().startsWith('Exception: ')
                    ? error.toString().substring('Exception: '.length)
                    : 'Não foi possível conectar à API. Verifique a conexão e tente novamente.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _tentarNovamente,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final pdf = snapshot.requireData;
          return PdfPreview(
            build: (_) async => pdf,
            pdfFileName: 'meus_estacionamentos.pdf',
            canChangePageFormat: false,
            canChangeOrientation: false,
          );
        },
      ),
    );
  }
}
