import 'package:intl/intl.dart';

class Fmt {
  static final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _dataHora = DateFormat('dd/MM/yyyy HH:mm');
  static final _hora = DateFormat('HH:mm');
  static const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  static String moeda(num? valor) => _moeda.format(valor ?? 0);

  static String dataHora(DateTime? data) => data == null ? '-' : _dataHora.format(data);

  static String hora(DateTime? data) => data == null ? '-' : _hora.format(data);

  static String diaSemana(DateTime data) => _diasSemana[data.weekday - 1];

  static String duracao(Duration d) {
    final horas = d.inHours;
    final minutos = d.inMinutes.remainder(60);
    if (horas == 0) return '${d.inMinutes} min';
    return '${horas}h ${minutos.toString().padLeft(2, '0')}min';
  }

  static String cpf(String? cpf) {
    if (cpf == null || cpf.length != 11) return cpf ?? '-';
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  static String cpfMascarado(String? cpf) {
    if (cpf == null || cpf.length != 11) return '***';
    return '***.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-**';
  }

  static DateTime? parseData(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
