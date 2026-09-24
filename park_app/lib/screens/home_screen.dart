import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'checkin_screen.dart';
import 'relatorio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, int>> _vagasFuture;

  @override
  void initState() {
    super.initState();
    _vagasFuture = _buscarContagemVagas();
  }

  Future<Map<String, int>> _buscarContagemVagas() async {
    final response = await ApiService.get('/vagas');

    if (response.statusCode == 200) {
      final List<dynamic> vagas = jsonDecode(response.body);
      int livres = 0;
      int ocupadas = 0;

      for (var vaga in vagas) {
        if (vaga['status'] == 'LIVRE') {
          livres++;
        } else if (vaga['status'] == 'OCUPADA') {
          ocupadas++;
        }
      }

      return {'livres': livres, 'ocupadas': ocupadas};
    } else {
      // Retorna zerado em caso de resposta sem dados
      return {'livres': 0, 'ocupadas': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, motorista!'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _vagasFuture = _buscarContagemVagas();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, int>>(
              future: _vagasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final livres = snapshot.data?['livres'] ?? 0;
                final ocupadas = snapshot.data?['ocupadas'] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$livres',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'vagas livres',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$ocupadas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'ocupadas',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RelatorioScreen()),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Meu relatório em PDF (cliente)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckInScreen()),
                );
                // Atualiza os contadores ao voltar do check-in
                setState(() {
                  _vagasFuture = _buscarContagemVagas();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Realizar Check-in',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
