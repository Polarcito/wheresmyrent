import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheresmyrent/model/payment.dart';
import 'package:wheresmyrent/model/property.dart';

class AddPaymentScreen extends StatefulWidget {
  final Property property;

  const AddPaymentScreen({super.key, required this.property});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isPaid = true;
  final _commentController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedPayments = [...widget.property.payments];
    updatedPayments.add(Payment(date: _selectedDate, isPaid: _isPaid, comment: _commentController.text.trim()));

    final updatedProperty = Property(
      id: widget.property.id,
      name: widget.property.name,
      address: widget.property.address,
      tenantName: widget.property.tenantName,
      monthlyRent: widget.property.monthlyRent,
      dueDay: widget.property.dueDay,
      startDate: widget.property.startDate,
      endDate: widget.property.endDate,
      isActive: widget.property.isActive,
      contractFilePath: widget.property.contractFilePath,
      initialPhotos: widget.property.initialPhotos,
      payments: updatedPayments,
    );

    widget.property
      //..name = updatedProperty.name // Puedes copiar más campos si editas alguno
      ..payments.clear()
      ..payments.addAll(updatedPayments)
      ..save();

    Navigator.pop(context);
  }

    @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().format(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text('Payment Date: $dateText'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SwitchListTile(
                title: const Text('Payment Completed'),
                value: _isPaid,
                onChanged: (val) => setState(() => _isPaid = val),
              ),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: "Comment"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Payment'),
              )
            ],
          ),
        ) 
      ),
    );
  }
}
