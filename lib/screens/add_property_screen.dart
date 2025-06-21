import 'package:flutter/material.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({Key? key}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _rentController = TextEditingController();

  int _selectedDueDay = 1;
  DateTime? _startDate;

  void _submit() {
    if (_formKey.currentState!.validate() && _startDate != null) {
      final newProperty = Property(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        tenantName: _tenantNameController.text.trim(),
        monthlyRent: double.tryParse(_rentController.text.trim()) ?? 0,
        dueDay: _selectedDueDay,
        startDate: _startDate!,
      );

      // Aquí podrías guardar la propiedad localmente o pasarla de vuelta
      Navigator.pop(context, newProperty);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _tenantNameController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        _startDate != null ? DateFormat.yMMMd().format(_startDate!) : 'Select date';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Property"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Property Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              TextFormField(
                controller: _tenantNameController,
                decoration: const InputDecoration(labelText: "Tenant Name"),
              ),
              TextFormField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Monthly Rent"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedDueDay,
                decoration: const InputDecoration(labelText: "Due Day"),
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("${index + 1}"),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDueDay = value);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text("Start Date: $dateFormatted"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save Property"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
