import 'package:flutter/material.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction.dart' as model;
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionController transactionController;
  final model.Transaction? transactionToEdit;
  final int userId;

  const TransactionFormScreen({
    super.key,
    required this.transactionController,
    this.transactionToEdit,
    required this.userId,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'expense';
  String _categorie = 'Alimentation';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  double _priority = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _montantController.text = tx.montant.toString();
      _descriptionController.text = tx.description;
      _type = tx.type;
      _categorie = tx.categorie;
      _selectedDate = DateTime.parse(tx.date);
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final newTx = model.Transaction(
        id: widget.transactionToEdit?.id,
        userId: widget.userId,
        type: _type,
        montant: double.parse(_montantController.text),
        categorie: _categorie,
        description: _descriptionController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      if (widget.transactionToEdit == null) {
        await widget.transactionController.addTransaction(newTx);
      } else {
        await widget.transactionController.updateTransaction(newTx);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine categories based on type
    final currentCategories = _type == 'expense' ? AppCategories.depenses : AppCategories.revenus;
    // Check if current category is still valid for this type
    if (!currentCategories.any((c) => c['name'] == _categorie)) {
      _categorie = currentCategories.first['name'] as String;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Nouvelle Transaction' : 'Modifier Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SegmentedButton for Type
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Dépense')),
                  ButtonSegment(value: 'income', label: Text('Revenu')),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // TextField for Montant
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(labelText: 'Montant (MAD)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // TextField for Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Categories as Chips
              const Text('Catégorie:'),
              Wrap(
                spacing: 8.0,
                children: currentCategories.map((catMap) {
                  final cat = catMap['name'] as String;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: _categorie == cat,
                    selectedColor: (catMap['color'] as Color).withValues(alpha: 0.3),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _categorie = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // DatePicker trigger
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                  ),
                  OutlinedButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Choisir Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Switch for Recurring
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transaction Récurrente'),
                  Switch(
                    value: _isRecurring,
                    onChanged: (val) {
                      setState(() {
                        _isRecurring = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Slider for Priority
              const Text('Niveau d\'importance (Optionnel):'),
              Slider(
                value: _priority,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: _priority.round().toString(),
                onChanged: (val) {
                  setState(() {
                    _priority = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // ElevatedButton for Save
              ElevatedButton(
                onPressed: widget.transactionController.isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: widget.transactionController.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 8),

              // TextButton to Cancel
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
