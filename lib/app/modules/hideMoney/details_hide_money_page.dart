import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/shared/widgets/pages/complete_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../app_widget.dart';
import '../../shared/widgets/form/bottom_sheet_form.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text[0].toUpperCase() + text.substring(1);
}

class DetailsHideMoneyPage extends StatefulWidget {
  final String? hideMoneyItemId;
  final String? title;
  final String? description;
  final String? stats;
  final List<dynamic> transactions;

  const DetailsHideMoneyPage({
    Key? key,
    required this.hideMoneyItemId,
    required this.title,
    required this.description,
    required this.transactions,
    required this.stats,
  }) : super(key: key);

  @override
  State<DetailsHideMoneyPage> createState() => _DetailsHideMoneyPageState();
}

class _DetailsHideMoneyPageState extends State<DetailsHideMoneyPage> {
  late CollectionReference<Map<String, dynamic>> hideMoneyCollectionRef;

  @override
  void initState() {
    super.initState();
    hideMoneyCollectionRef =
        FirebaseFirestore.instance.collection('hideMoneyCollection');
  }

  _openLittleBoxFormModal(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      context: context,
      builder: (ctx) {
        return CustomBottomSheetForm(
          isEditing: false,
          isHideMoney: false,
          isHideMoneyTransaction: true,
          hideMoneyTransactionId: widget.hideMoneyItemId,
        );
      },
    );
  }

  _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Concluir'),
          content: const Text('Tem certeza de que deseja concluir?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateStats('closed');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletionAnimation(
                      nextPage: AppPage(selectedIndex: 1),
                    ),
                  ),
                  (route) => false, //
                );
              },
              child: const Text('Confirmar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  _updateStats(String newStats) {
    hideMoneyCollectionRef.doc(widget.hideMoneyItemId).update({
      'stats': newStats,
    }).then((value) {
      debugPrint('Status atualizado com sucesso para $newStats');
    }).catchError((error) {
      debugPrint('Erro ao atualizar o status: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: hideMoneyCollectionRef.doc(widget.hideMoneyItemId).snapshots(),
      builder: (context, snapshot) {
        final size = MediaQuery.of(context).size;
        initializeDateFormatting('pt_BR', null);

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final documentData = snapshot.data!.data() as Map<String, dynamic>;
        final transactions = documentData['transactions'] as List<dynamic>;
        final double totalValue = transactions.fold(
          0,
          (sum, transaction) => sum + transaction['value'],
        );

        final screenHeight = size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom -
            70;

        final listViewHeight = transactions.length * 72.0;
        final listViewContainerHeight =
            listViewHeight < screenHeight ? listViewHeight : screenHeight;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: size,
            child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              height: size.height * 0.12,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
                color: Colors.cyan,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                      child: Text(
                        capitalizeFirstLetter(widget.title!),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        widget.description! == ''
                            ? 'Sem descrição'
                            : widget.description!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        'Valor Guardado',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        '${totalValue.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        'Histórico',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: transactions.length <= 5
                          ? size.height * 0.5
                          : listViewContainerHeight,
                      width: size.width * 1,
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final dateTimestamp =
                              transactions[index]['createdAt'] as Timestamp;
                          final date = dateTimestamp.toDate();

                          return ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: transactions[index]['type'].toString() ==
                                      'add'
                                  ? const Icon(
                                      Icons.attach_money_outlined,
                                      color: Colors.green,
                                    )
                                  : const Icon(
                                      Icons.money_off,
                                      color: Colors.red,
                                    ),
                            ),
                            title:
                                transactions[index]['type'].toString() == 'add'
                                    ? const Text('Aplicação de fundo')
                                    : const Text('Retirada de fundo'),
                            subtitle: Text(
                                DateFormat('d MMM y', 'pt_BR').format(date)),
                            trailing: Text(
                              '${transactions[index]['value'].toStringAsFixed(2)} €',
                              style: TextStyle(
                                color: transactions[index]['type'].toString() ==
                                        'add'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 75,
                    ),
                  ],
                ),
              ),
              widget.stats == 'open'
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (widget.stats == 'open')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showConfirmationDialog(context);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Concluir'),
                                ),
                              if (widget.stats == 'open')
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _openLittleBoxFormModal(context);
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Movimentar'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
