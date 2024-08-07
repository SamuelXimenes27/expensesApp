class TransactionModel {
  final String id;
  final String title;
  final double value;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
  });
}
