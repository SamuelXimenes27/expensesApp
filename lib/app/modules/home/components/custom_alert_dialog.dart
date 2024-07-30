import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/shared/widgets/form/bottom_sheet_form.dart';
import 'package:flutter/material.dart';

// import 'card_expense_form.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text[0].toUpperCase() + text.substring(1);
}

class RemoveAlertDialog extends StatefulWidget {
  final String collectionId;
  // ignore: prefer_typing_uninitialized_variables
  final collectionData;

  const RemoveAlertDialog({
    Key? key,
    required this.collectionId,
    required this.collectionData,
  }) : super(key: key);

  @override
  _RemoveAlertDialogState createState() => _RemoveAlertDialogState();
}

class _RemoveAlertDialogState extends State<RemoveAlertDialog> {
  bool removeConfirm = false;

  void toggleRemoveConfirm() {
    setState(() {
      removeConfirm = !removeConfirm;
    });
  }

  Future<void> deleteCollection() async {
    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('transactionCollection')
          .doc(widget.collectionId);

      await collectionRef.delete();
      debugPrint('Sucesso ao excluir a coleção');
    } catch (e) {
      debugPrint('Erro ao excluir a coleção: $e');
    }
  }

  Future<void> _openEditTransactionForm(BuildContext context) async {
    Navigator.pop(context);

    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      context: context,
      builder: (ctx) {
        return CustomBottomSheetForm(
          isEditing: true,
          title: widget.collectionData['title'],
          type: widget.collectionData['type'],
          value: widget.collectionData['value'].toString(),
          description: widget.collectionData['description'],
          documentId: widget.collectionId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Center(
        child: Text(
          capitalizeFirstLetter(widget.collectionData['title']),
          style: const TextStyle(
            fontSize: 26,
          ),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16.0),
          _buildInfoRow('Usuário', widget.collectionData['user']),
          _buildInfoRow('Tipo de Gasto', widget.collectionData['type']),
          _buildInfoRow('Valor', '€ ${widget.collectionData['value']}'),
          _buildInfoRow(
            'Descrição',
            widget.collectionData['description'] == ''
                ? 'Sem descrição'
                : widget.collectionData['description'],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (!removeConfirm) {
                toggleRemoveConfirm();
              } else {
                deleteCollection().then((value) => Navigator.pop(context));
              }
            },
            child: Text(
              removeConfirm ? 'Tem certeza?' : 'Excluir',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                letterSpacing: 1.25,
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: removeConfirm ? Colors.green : Colors.redAccent,
              minimumSize: Size(
                double.infinity,
                MediaQuery.of(context).size.width * 0.15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              _openEditTransactionForm(context);
            },
            child: const Text(
              'Editar Transação',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                letterSpacing: 1.25,
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[400],
              minimumSize: Size(
                double.infinity,
                MediaQuery.of(context).size.width * 0.15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Fechar',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                letterSpacing: 1.25,
                color: Colors.black,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: Size(
                double.infinity,
                MediaQuery.of(context).size.width * 0.15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}
