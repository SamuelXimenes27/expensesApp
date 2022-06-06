import 'transaction.dart';

class Transactions {
  final transactions = [
    Transaction(
      id: 't1',
      title: "Conta de Luz",
      value: 289.60,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't2',
      title: "Conta de Agua",
      value: 80.00,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't3',
      title: "Fatura Itau",
      value: 1793.13,
      date: DateTime.now(),
    )
  ];
}
