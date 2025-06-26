import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wheresmyrent/model/payment.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class AddPaymentScreen extends StatefulWidget {
  final Property property;
  final DateTime? preselectedDate;

  const AddPaymentScreen({super.key, required this.property, this.preselectedDate});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  bool _isPaid = true;
  final _commentController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate ?? DateTime.now();

    Payment? existingPayment;

    try {
      existingPayment = widget.property.payments.firstWhere(
        (p) => p.date.year == _selectedDate.year && p.date.month == _selectedDate.month,
      );
    } catch (e) {
      existingPayment = null;
    }

    if (existingPayment != null) {
      _isPaid = existingPayment.isPaid;
      _commentController.text = existingPayment.comment ?? '';
      if (existingPayment.photoPath != null && existingPayment.photoPath!.isNotEmpty) {
        _selectedImage = File(existingPayment.photoPath!);
      }
    }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Select Image Source"),
        children: [
          SimpleDialogOption(
            child: const Text("Camera"),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          SimpleDialogOption(
            child: const Text("Gallery"),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<String?> savePaymentPhoto(File selectedFile, String propertyId, DateTime paymentDate) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/payment_photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final extension = path.extension(selectedFile.path);
    final fileName = '${propertyId}_${paymentDate.toIso8601String().substring(0, 10)}$extension';
    final newPath = path.join(photoDir.path, fileName);

    final savedFile = await selectedFile.copy(newPath);
    return savedFile.path;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Elimina cualquier pago existente del mismo mes y año
    final payments = [...widget.property.payments];
    final existingPayment = payments.firstWhere(
      (p) => p.date.month == _selectedDate.month && p.date.year == _selectedDate.year,
      orElse: () => Payment(date: _selectedDate, isPaid: false, comment: _commentController.text.trim()),
    );

    // 🔥 Borra la foto anterior si se está reemplazando
    if (existingPayment.photoPath != null &&
        existingPayment.photoPath != _selectedImage?.path) {
      final old = File(existingPayment.photoPath!);
      if (await old.exists()) await old.delete();
    }

    String? internalImagePath;
    if (_selectedImage != null) {
      internalImagePath = await savePaymentPhoto(_selectedImage!, widget.property.id, _selectedDate);
    }

    payments.removeWhere((p) =>
        p.date.month == _selectedDate.month &&
        p.date.year == _selectedDate.year);

    payments.add(Payment(
      date: _selectedDate,
      isPaid: _isPaid,
      comment: _commentController.text.trim(),
      photoPath: internalImagePath,
    ));

    widget.property
      ..payments.clear()
      ..payments.addAll(payments)
      ..save();

    Navigator.pop(context);
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
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Add Photo'),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedImage != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _selectedImage = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Payment'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
