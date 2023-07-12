import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomBottomSheetForm extends StatefulWidget {
  final bool isTransaction;
  final bool isHideMoney;
  final bool isEditing;
  final bool isHideMoneyTransaction;
  final String? title;
  final String? type;
  final String? value;
  final String? description;
  final String? documentId;
  final String? hideMoneyTransactionId;

  const CustomBottomSheetForm({
    this.title,
    this.type,
    this.value,
    this.description,
    this.documentId,
    this.hideMoneyTransactionId,
    this.isEditing = false,
    this.isTransaction = false,
    this.isHideMoney = false,
    this.isHideMoneyTransaction = false,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomBottomSheetForm> createState() => _CustomBottomSheetFormState();
}

class _CustomBottomSheetFormState extends State<CustomBottomSheetForm> {
  final transactionFormController = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final valueController = TextEditingController();
  String? selectedType;
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  bool _isExpense = false;
  bool _wasExpenseTogether = false;
  bool haveDescription = false;

  String userName = '';

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title ?? '';
    valueController.text = widget.value ?? '';
    descriptionController.text = widget.description ?? '';
    selectedType = widget.type ?? selectedType;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.selection = TextSelection.fromPosition(
          TextPosition(offset: titleController.text.length));
      valueController.selection = TextSelection.fromPosition(
          TextPosition(offset: valueController.text.length));
    });
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? '';
      });
    }
  }

  Future<List<DocumentSnapshot>> getTransactionList() async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('transactionCollection');

      final querySnapshot =
          await collectionRef.orderBy('createdAt', descending: true).get();

      return querySnapshot.docs;
    } catch (e) {
      debugPrint('Erro ao obter lista de transações: $e');
      return [];
    }
  }

  _submitForm([
    bool? isTransaction,
    bool? isEditing,
    bool? isHideMoney,
    bool? isHideMoneyTransaction,
  ]) async {
    final title = titleController.text;
    final value = double.tryParse(valueController.text) ?? 0.0;
    final adjustedValue = _isExpense ? -value : value;
    final typeOfTransaction = selectedType;
    final descriptionOfTransaction = descriptionController.text;

    if (isHideMoneyTransaction == false) {
      if (title.isEmpty) {
        return;
      }
    }
    await loadUserData();

    if (isTransaction == true) {
      await addDataTransactionFirestore(
        title,
        userName,
        adjustedValue,
        typeOfTransaction ?? 'Outros',
        descriptionOfTransaction,
        _wasExpenseTogether,
        selectedDate ?? DateTime.now(),
      );
      Navigator.pop(context);
    } else if (isEditing == true) {
      await updateDataTransactionFirestore(
        title,
        adjustedValue,
        typeOfTransaction!,
        descriptionOfTransaction,
      );
      Navigator.pop(context);
    } else if (isHideMoney == true) {
      await addDataHideMoneyFirestore(
        title,
        userName,
        value,
        descriptionOfTransaction,
      );
      Navigator.pop(context);
    } else if (isHideMoneyTransaction == true) {
      await updateDataHideMoneyFirestore(
        value,
        _isExpense ? 'remove' : 'add',
      );
      Navigator.pop(context);
    } else {
      debugPrint('Erro ao enviar o formulário!');
    }
  }

  Future<void> addDataHideMoneyFirestore(
    String title,
    String user,
    double value,
    String description,
  ) async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('hideMoneyCollection');

      final transaction = {
        'value': value,
        'type': 'add',
        'createdAt': DateTime.now(),
      };

      await collectionRef.add({
        'title': title,
        'user': user,
        'transactions': [transaction],
        'description': description,
        'stats': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Dados inseridos com sucesso no Firestore!');
    } catch (e) {
      debugPrint('Erro ao inserir dados no Firestore: $e');
    }
  }

  Future<void> addDataTransactionFirestore(
    String title,
    String user,
    double value,
    String type,
    String description,
    bool wasExpenseTogether,
    DateTime date,
  ) async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('transactionCollection');

      await collectionRef.add({
        'title': title,
        'user': user,
        'value': value,
        'date': date,
        'type': type,
        'description': description,
        'wasExpenseTogether': wasExpenseTogether,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Dados inseridos com sucesso no Firestore!');
    } catch (e) {
      debugPrint('Erro ao inserir dados no Firestore: $e');
    }
  }

  Future<void> updateDataTransactionFirestore(
    String title,
    double value,
    String type,
    String description,
  ) async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('transactionCollection');

      await collectionRef.doc(widget.documentId).update({
        'title': title,
        'value': value,
        'type': type,
        'description': description,
      });

      debugPrint('Dados atualizados com sucesso no Firestore!');
    } catch (e) {
      debugPrint('Erro ao atualizar dados no Firestore: $e');
    }
  }

  Future<void> updateDataHideMoneyFirestore(double value, String type) async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection('hideMoneyCollection');

      final transaction = {
        'value': value,
        'type': type,
        'createdAt': DateTime.now(),
      };

      await collectionRef.doc(widget.hideMoneyTransactionId).update({
        'transactions': FieldValue.arrayUnion([transaction]),
      });

      debugPrint('Dados adicionados com sucesso no Firestore!');
    } catch (e) {
      debugPrint('Erro ao adicionar dados no Firestore: $e');
    }
  }

  _showDatePicker() {
    final initialDate = selectedDate ?? DateTime.now();

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        selectedDate = pickedDate;
      });
    });
  }

  List<DropdownMenuItem<String>> getDropdownItems() {
    List<String> options = [
      'Comida',
      'Roupa',
      'Ganhos',
      'Outros',
    ];

    List<DropdownMenuItem<String>> dropdownItems = [];

    for (String option in options) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        ),
      );
    }

    return dropdownItems;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: transactionFormController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Center(
                  child: Text(
                    widget.isHideMoney == false
                        ? widget.isEditing == false
                            ? widget.isHideMoneyTransaction == true
                                ? 'Movimentar a Caixinha'
                                : 'Nova Transação'
                            : 'Editando a Transação'
                        : 'Nova Caixinha',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              widget.isHideMoneyTransaction == false
                  ? TextFormField(
                      decoration: InputDecoration(
                        labelText: widget.isHideMoney == false
                            ? 'Título'
                            : 'Nome da Caixinha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: titleController,
                      onFieldSubmitted: (_) => _submitForm(),
                    )
                  : Container(),
              widget.isHideMoneyTransaction == false
                  ? const SizedBox(height: 16)
                  : Container(),
              TextFormField(
                decoration: InputDecoration(
                  labelText: widget.isHideMoney == false
                      ? 'Valor (€)'
                      : 'Valor (€) que irá guardar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: valueController,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _submitForm(),
              ),
              const SizedBox(height: 16),
              widget.isHideMoneyTransaction == false
                  ? widget.isHideMoney == false
                      ? DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Tipo de Gasto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // errorText: 'Selecione um tipo',
                          ),
                          value: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                          items: getDropdownItems(),
                        )
                      : Container()
                  : Container(),
              widget.isHideMoneyTransaction == false
                  ? widget.isHideMoney == false
                      ? const SizedBox(height: 16)
                      : Container()
                  : Container(),
              widget.isHideMoneyTransaction == false
                  ? widget.isHideMoney == false
                      ? haveDescription == false
                          ? Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    haveDescription = true;
                                  });
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Deseja adicionar uma descrição?',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : TextFormField(
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Descrição Detalhada',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: descriptionController,
                              onFieldSubmitted: (_) => _submitForm(),
                            )
                      : TextFormField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: widget.isHideMoney == false
                                ? 'Descrição Detalhada'
                                : 'Descrição da Caixinha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          controller: descriptionController,
                          onFieldSubmitted: (_) => _submitForm(),
                        )
                  : Container(),
              widget.isHideMoneyTransaction == false
                  ? const SizedBox(height: 10)
                  : Container(),
              widget.isHideMoney == false
                  ? widget.isEditing == false
                      ? Row(
                          children: [
                            Checkbox(
                              value: _isExpense,
                              onChanged: (value) {
                                setState(() {
                                  _isExpense = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isHideMoneyTransaction == false
                                  ? 'Essa transação foi um gasto?'
                                  : 'Você está tirando dinheiro da caixinha?',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Container()
                  : Container(),
              widget.isHideMoney == false
                  ? widget.isEditing == false
                      ? Row(
                          children: [
                            Checkbox(
                              value: _wasExpenseTogether,
                              onChanged: (value) {
                                setState(() {
                                  _wasExpenseTogether = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Foi um gasto conjunto?',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Container()
                  : Container(),
              widget.isHideMoneyTransaction == false
                  ? widget.isHideMoney == false
                      ? widget.isEditing == false
                          ? SizedBox(
                              height: 70,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          selectedDate == null
                                              ? 'Nenhuma data selecionada!'
                                              : 'Data Selecionada: ${DateFormat('dd/MM/y').format(selectedDate!)}',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _showDatePicker,
                                        child: const Text(
                                          'Selecionar Data',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container()
                      : Container()
                  : Container(),
              ElevatedButton(
                onPressed: () async {
                  if (transactionFormController.currentState!.validate()) {
                    if (widget.isHideMoney == false &&
                        widget.isHideMoneyTransaction == false) {
                      _submitForm(
                        widget.isTransaction,
                        widget.isEditing,
                        false,
                        false,
                      );
                    } else if (widget.isHideMoney == true &&
                        widget.isHideMoneyTransaction == false) {
                      _submitForm(
                        false,
                        false,
                        true,
                        false,
                      );
                    } else if (widget.isHideMoneyTransaction == true) {
                      _submitForm(
                        false,
                        false,
                        false,
                        true,
                      );
                    }
                  }
                },
                child: Text(
                  widget.isHideMoney == false
                      ? widget.isEditing == false
                          ? 'Adicionar Transação'
                          : 'Atualizar Transação'
                      : 'Criar Caixinha',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
