import 'package:flutter/material.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? existingProperty;
  const AddPropertyScreen({super.key, this.existingProperty});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _tenantNameController = TextEditingController();
  final _tenantEmailController = TextEditingController();
  final _tenantPhoneController = TextEditingController();
  final _rentController = TextEditingController();

  int _selectedDueDay = 1;
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingProperty != null) {
      final p = widget.existingProperty!;
      _nameController.text = p.name;
      _addressController.text = p.address;
      _tenantNameController.text = p.tenantName;
      _tenantEmailController.text = p.tenantEmail ?? '';
      _tenantPhoneController.text = p.tenantPhone ?? '';
      _rentController.text = p.monthlyRent.toString();
      _selectedDueDay = p.dueDay;
      _startDate = p.startDate;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;

    final box = Hive.box<Property>(Config.boxName);

    if (widget.existingProperty != null) {
      // Edición
      final p = widget.existingProperty!;
      p
        ..name = _nameController.text.trim()
        ..address = _addressController.text.trim()
        ..tenantName = _tenantNameController.text.trim()
        ..tenantEmail = _tenantEmailController.text.trim()
        ..tenantPhone = _tenantPhoneController.text.trim()
        ..monthlyRent = double.tryParse(_rentController.text.trim()) ?? 0
        ..dueDay = _selectedDueDay
        ..startDate = _startDate!;
      await p.save();
      if (context.mounted) Navigator.pop(context, p);
    } else {
      // Nueva propiedad
      final newProperty = Property(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        tenantName: _tenantNameController.text.trim(),
        monthlyRent: double.tryParse(_rentController.text.trim()) ?? 0,
        tenantEmail: _tenantEmailController.text.trim(),
        tenantPhone: _tenantPhoneController.text.trim(),
        dueDay: _selectedDueDay,
        startDate: _startDate!,
      );
      await box.put(newProperty.id, newProperty);
      if (context.mounted) Navigator.pop(context, newProperty);
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
        backgroundColor: AppColors.primary,
        title: Text(
          "Add Property",
          style: const TextStyle(color: Colors.white)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
          children: [
            const Text(
              'Property Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Property Name"),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextFormField(
              controller: _rentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Monthly Rent"),
            ),
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
            ListTile(
              title: Text("Start Date: $dateFormatted"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
            const SizedBox(height: 24),

            const Text(
              'Tenant Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tenantNameController,
              decoration: const InputDecoration(labelText: "Tenant Name"),
            ),
            TextFormField(
              controller: _tenantEmailController,
              decoration: const InputDecoration(labelText: "Tenant Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _tenantPhoneController,
              decoration: const InputDecoration(labelText: "Tenant Phone"),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Save Property"),
            )
          ],
        ),
        ),
      ),
    );
  }
}
