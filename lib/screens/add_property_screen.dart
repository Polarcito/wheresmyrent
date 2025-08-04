import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:uuid/uuid.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? existingProperty; // <-- NUEVO

  const AddPropertyScreen({super.key, this.existingProperty});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int currentStep = 0;
  int? _selectedDueDay = 5;

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  // Step 1
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  DateTime? _startDate;

  // Step 2
  final TextEditingController _tenantNameController = TextEditingController();
  final TextEditingController _tenantEmailController = TextEditingController();
  final TextEditingController _tenantPhoneController = TextEditingController();

  // Step 3
  String? _contractFilePath;
  List<String> _initialPhotos = [];

  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final p = widget.existingProperty;
    if (p != null) {
      _nameController.text = p.name;
      _addressController.text = p.address;
      _rentController.text = p.monthlyRent.toString();
      _selectedDueDay = p.dueDay;
      _startDate = p.startDate;

      _tenantNameController.text = p.tenantName;
      _tenantEmailController.text = p.tenantEmail;
      _tenantPhoneController.text = p.tenantPhone;

      _contractFilePath = p.contractFilePath;
      _initialPhotos = List<String>.from(p.initialPhotos);
    }
  }

  void _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        _startDate = selected;
      });
    }
  }

  void _pickContractFile() async {
    final file = await openFile();
    if (file != null) {
      setState(() {
        _contractFilePath = file.path;
      });
    }
  }

  void _pickInitialPhotos() async {
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    setState(() {
      _initialPhotos.addAll(picked.map((e) => e.path));
    });
  }

  void _nextStep() {
    if (_formKeys[currentStep].currentState!.validate()) {
      if (currentStep < 2) {
        setState(() {
          currentStep++;
        });
      } else {
        _saveProperty();
      }
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void _saveProperty() async {
    final isEditing = widget.existingProperty != null;

    if (isEditing) {
      final property = widget.existingProperty!;
      property.name = _nameController.text;
      property.address = _addressController.text;
      property.monthlyRent = double.tryParse(_rentController.text.replaceAll(',', '.')) ?? 0;
      property.dueDay = _selectedDueDay!;
      property.startDate = _startDate!;
      property.tenantName = _tenantNameController.text;
      property.tenantEmail = _tenantEmailController.text;
      property.tenantPhone = _tenantPhoneController.text;
      property.contractFilePath = _contractFilePath;
      property.initialPhotos = _initialPhotos;

      await property.save();
    } else {
      final property = Property(
        id: _uuid.v4(),
        name: _nameController.text,
        address: _addressController.text,
        monthlyRent: double.tryParse(_rentController.text.replaceAll(',', '.')) ?? 0,
        dueDay: _selectedDueDay!,
        startDate: _startDate!,
        tenantName: _tenantNameController.text,
        tenantEmail: _tenantEmailController.text,
        tenantPhone: _tenantPhoneController.text,
        contractFilePath: _contractFilePath,
        initialPhotos: _initialPhotos,
      );

      final box = Hive.box<Property>('properties');
      await box.put(property.id, property);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Propiedad actualizada' : 'Propiedad guardada'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Propiedad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeys[currentStep],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: steps[currentStep]),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text('Volver'),
                    ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(currentStep < 2 ? 'Siguiente' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre de la propiedad'),
          validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
        ),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Dirección'),
          validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
        ),
        TextFormField(
          controller: _rentController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
          ],
          decoration: const InputDecoration(labelText: 'Arriendo mensual'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Campo obligatorio';

            // Reemplazar coma por punto si el usuario escribe con coma decimal
            final normalized = value.replaceAll(',', '.');

            final parsed = double.tryParse(normalized);
            if (parsed == null) return 'Ingresa un número válido';
            return null;
          },
        ),
        DropdownButtonFormField<int>(
          value: _selectedDueDay,
          decoration: const InputDecoration(labelText: 'Día de vencimiento'),
          items: List.generate(31, (index) {
            final day = index + 1;
            return DropdownMenuItem(
              value: day,
              child: Text(day.toString()),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedDueDay = value;
            });
          },
          validator: (value) =>
              value == null ? 'Selecciona un día de vencimiento' : null,
        ),
        const SizedBox(height: 12),
        Text('Fecha de inicio del contrato:'),
        Row(
          children: [
            Expanded(
              child: Text(
                _startDate != null
                    ? '📅 ${DateFormat.yMMMd().format(_startDate!)}'
                    : 'Fecha no seleccionada',
                style: TextStyle(
                  fontSize: 16,
                  color: _startDate != null ? Colors.black : Colors.red,
                ),
              ),
            ),
            IconButton(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today),
              tooltip: 'Seleccionar fecha',
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      children: [
        TextFormField(
          controller: _tenantNameController,
          decoration: const InputDecoration(labelText: 'Nombre del arrendatario'),
          validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
        ),
        TextFormField(
          controller: _tenantEmailController,
          decoration: const InputDecoration(labelText: 'Correo electrónico'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Obligatorio';
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            return emailRegex.hasMatch(value) ? null : 'Correo no válido';
          },
        ),
        TextFormField(
          controller: _tenantPhoneController,
          decoration: const InputDecoration(labelText: 'Teléfono'),
          validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return ListView(
      children: [
        const Text('Archivo de contrato (opcional)'),
        TextButton(
          onPressed: _pickContractFile,
          child: Text(_contractFilePath != null ? '📄 Archivo seleccionado' : 'Seleccionar archivo'),
        ),
        const SizedBox(height: 16),
        const Text('Fotos iniciales del inmueble (opcional)'),
        TextButton(
          onPressed: _pickInitialPhotos,
          child: const Text('Seleccionar fotos'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _initialPhotos.map((path) {
            return Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover);
          }).toList(),
        ),
      ],
    );
  }
}
