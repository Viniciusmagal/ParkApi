import 'package:flutter/material.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/cliente/cliente_shell.dart';
import 'screens/login_screen.dart';
import 'services/session.dart';

void main() {
  runApp(const ParkApp());
}

class ParkApp extends StatelessWidget {
  const ParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkAPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  static Widget homeFor() => Session.isAdmin ? const AdminShell() : const ClienteShell();

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<bool> _restored = Session.restore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restored,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data == true ? SessionGate.homeFor() : const LoginScreen();
      },
    );
  }
}
