import 'transaction.dart';

class Transactions {
  final transactions = [
    Transaction(
      id: 't1',
      title: "Conta de Luz",
      value: 289.60,
      date: DateTime(2022, 4, 5),
    ),
    Transaction(
      id: 't2',
      title: "Conta de Agua",
      value: 80.00,
      date: DateTime(2022, 3, 7),
    ),
    Transaction(
      id: 't3',
      title: "Fatura Itau",
      value: 1793.13,
      date: DateTime(2022, 5, 25),
    ),
    Transaction(
      id: 't4',
      title: "Fatura Nubank",
      value: 4326.89,
      date: DateTime.now(),
    )
  ];
}
