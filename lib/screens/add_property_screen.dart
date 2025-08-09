import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:uuid/uuid.dart';
import 'package:wheresmyrent/model/services/file_storage_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? existingProperty;

  const AddPropertyScreen({super.key, this.existingProperty});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int currentStep = 0;
  int? _selectedDueDay = 5;
  String? _propertyId;

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  DateTime? _startDate;

  final TextEditingController _tenantNameController = TextEditingController();
  final TextEditingController _tenantEmailController = TextEditingController();
  final TextEditingController _tenantPhoneController = TextEditingController();

  String? _contractFilePath;
  List<String> _initialPhotos = [];

  final _uuid = const Uuid();

  final List<Map<String, String>> countryCodes = [
    {'code': '+61',  'name': 'Australia',      'flag': '🇦🇺', 'iso': 'AU'},
    {'code': '+54',  'name': 'Argentina',      'flag': '🇦🇷', 'iso': 'AR'},
    {'code': '+56',  'name': 'Chile',          'flag': '🇨🇱', 'iso': 'CL'},
    {'code': '+86',  'name': 'China',          'flag': '🇨🇳', 'iso': 'CN'},
    {'code': '+57',  'name': 'Colombia',       'flag': '🇨🇴', 'iso': 'CO'},
    {'code': '+20',  'name': 'Egipto',         'flag': '🇪🇬', 'iso': 'EG'},
    {'code': '+34',  'name': 'España',         'flag': '🇪🇸', 'iso': 'ES'},
    {'code': '+33',  'name': 'Francia',        'flag': '🇫🇷', 'iso': 'FR'},
    {'code': '+49',  'name': 'Alemania',       'flag': '🇩🇪', 'iso': 'DE'},
    {'code': '+91',  'name': 'India',          'flag': '🇮🇳', 'iso': 'IN'},
    {'code': '+62',  'name': 'Indonesia',      'flag': '🇮🇩', 'iso': 'ID'},
    {'code': '+972', 'name': 'Israel',         'flag': '🇮🇱', 'iso': 'IL'},
    {'code': '+81',  'name': 'Japón',          'flag': '🇯🇵', 'iso': 'JP'},
    {'code': '+82',  'name': 'Corea del Sur',  'flag': '🇰🇷', 'iso': 'KR'},
    {'code': '+60',  'name': 'Malasia',        'flag': '🇲🇾', 'iso': 'MY'},
    {'code': '+234', 'name': 'Nigeria',        'flag': '🇳🇬', 'iso': 'NG'},
    {'code': '+64',  'name': 'Nueva Zelanda',  'flag': '🇳🇿', 'iso': 'NZ'},
    {'code': '+47',  'name': 'Noruega',        'flag': '🇳🇴', 'iso': 'NO'},
    {'code': '+51',  'name': 'Perú',           'flag': '🇵🇪', 'iso': 'PE'},
    {'code': '+63',  'name': 'Filipinas',      'flag': '🇵🇭', 'iso': 'PH'},
    {'code': '+55',  'name': 'Brasil',         'flag': '🇧🇷', 'iso': 'BR'},
    {'code': '+44',  'name': 'Reino Unido',    'flag': '🇬🇧', 'iso': 'GB'},
    {'code': '+7',   'name': 'Rusia',          'flag': '🇷🇺', 'iso': 'RU'},
    {'code': '+358', 'name': 'Finlandia',      'flag': '🇫🇮', 'iso': 'FI'},
    {'code': '+46',  'name': 'Suecia',         'flag': '🇸🇪', 'iso': 'SE'},
    {'code': '+41',  'name': 'Suiza',          'flag': '🇨🇭', 'iso': 'CH'},
    {'code': '+27',  'name': 'Sudáfrica',      'flag': '🇿🇦', 'iso': 'ZA'},
    {'code': '+66',  'name': 'Tailandia',      'flag': '🇹🇭', 'iso': 'TH'},
    {'code': '+90',  'name': 'Turquía',        'flag': '🇹🇷', 'iso': 'TR'},
    {'code': '+1',   'name': 'USA',            'flag': '🇺🇸', 'iso': 'US'},
  ];

  String _tenantPhoneCode = '+56'; // valor por defecto
  String _selectedCountryCode = '+56'; // Valor inicial por defecto (Chile)

  @override
  void initState() {
    super.initState();
    final p = widget.existingProperty;

    if (p != null) {
      // Modo edición
      _propertyId = p.id;
      _nameController.text = p.name;
      _addressController.text = p.address;
      _rentController.text = p.monthlyRent.toString();
      _selectedDueDay = p.dueDay;
      _startDate = p.startDate;
      _tenantNameController.text = p.tenantName;
      _tenantEmailController.text = p.tenantEmail;
      _contractFilePath = p.contractFilePath;
      _initialPhotos = List<String>.from(p.initialPhotos);

      if (p.tenantPhoneNumber.isNotEmpty) {
        _tenantPhoneCode = p.tenantPhoneCode;
        _tenantPhoneController.text = p.tenantPhoneNumber;
      }
    } else {
      // Modo creación → generar id temporal
      _propertyId = _uuid.v4();
    }

    if (_tenantPhoneController.text.isEmpty) {
      _setInitialCountryCode();
    }
  }

  void _setInitialCountryCode() {
    final isoCode = ui.PlatformDispatcher.instance.locale.countryCode?.toUpperCase() ?? 'CL';

    final match = countryCodes.firstWhere(
      (c) => c['iso'] == isoCode,
      orElse: () => {'code': '+56'},
    );

    setState(() {
      _tenantPhoneCode = match['code']!;
    });
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
      final savedPath = await FileStorageService.copyToAppStorage(
        File(file.path),
        subdir: 'properties/$_propertyId/contracts',
        filename: 'contract${FileStorageService.extractExtension(file.path)}',
      );

      setState(() {
        _contractFilePath = savedPath;
      });
    }
  }

  void _pickInitialPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      final savedPaths = await Future.wait(picked.map(
        (xfile) => FileStorageService.copyXFileToAppStorage(
          xfile,
          subdir: 'properties/$_propertyId/initial_photos',
        ),
      ));

      setState(() {
        _initialPhotos
          ..clear() // así "pisas" las existentes si es edición
          ..addAll(savedPaths);
      });
    }
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
      property.tenantPhoneCode = _selectedCountryCode;
      property.tenantPhoneNumber = _tenantPhoneController.text;
      property.contractFilePath = _contractFilePath;
      property.initialPhotos = _initialPhotos;
      await property.save();
    } else {
      final property = Property(
        id: _propertyId!,
        name: _nameController.text,
        address: _addressController.text,
        monthlyRent: double.tryParse(_rentController.text.replaceAll(',', '.')) ?? 0,
        dueDay: _selectedDueDay!,
        startDate: _startDate!,
        tenantName: _tenantNameController.text,
        tenantEmail: _tenantEmailController.text,
        tenantPhoneCode: _selectedCountryCode,
        tenantPhoneNumber: _tenantPhoneController.text,

        contractFilePath: _contractFilePath,
        initialPhotos: _initialPhotos,
      );
      final box = Hive.box<Property>('properties');
      await box.put(property.id, property);
    }

    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? loc.addProperty_updated : loc.addProperty_saved),
      ),
    );
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final steps = [_buildStep1(loc), _buildStep2(loc), _buildStep3(loc)];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProperty != null ? loc.addProperty_updated : loc.addProperty_title),
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
                      child: Text(loc.addProperty_button_back),
                    )
                  else
                    const Spacer(),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(currentStep < 2 ? loc.addProperty_button_next : loc.addProperty_button_save),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations loc) {
    return ListView(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: loc.addProperty_step1_name),
          validator: (value) => value!.isEmpty ? loc.addProperty_required : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(labelText: loc.addProperty_step1_address),
          validator: (value) => value!.isEmpty ? loc.addProperty_required : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _rentController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$'))],
          decoration: InputDecoration(labelText: loc.addProperty_step1_rent),
          validator: (value) {
            if (value == null || value.isEmpty) return loc.addProperty_required_field;
            final normalized = value.replaceAll(',', '.');
            final parsed = double.tryParse(normalized);
            return parsed == null ? loc.addProperty_invalidNumber : null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedDueDay,
          decoration: InputDecoration(labelText: loc.addProperty_step1_dueDay),
          items: List.generate(31, (index) {
            final day = index + 1;
            return DropdownMenuItem(value: day, child: Text(day.toString()));
          }),
          onChanged: (value) {
            setState(() {
              _selectedDueDay = value;
            });
          },
          validator: (value) => value == null ? loc.addProperty_selectDueDay : null,
        ),
        const SizedBox(height: 16),
        Text(
          loc.addProperty_step1_startDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _startDate != null
                    ? '📅 ${DateFormat.yMMMd().format(_startDate!)}'
                    : loc.addProperty_step1_startDateNotSelected,
                style: TextStyle(
                  fontSize: 16,
                  color: _startDate != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            IconButton(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today),
              tooltip: loc.addProperty_step1_selectDate,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildStep2(AppLocalizations loc) {
    return ListView(
      children: [
        TextFormField(
          controller: _tenantNameController,
          decoration: InputDecoration(labelText: loc.addProperty_step2_tenantName),
          validator: (value) => value!.isEmpty ? loc.addProperty_required : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tenantEmailController,
          decoration: InputDecoration(labelText: loc.addProperty_step2_tenantEmail),
          validator: (value) {
            if (value == null || value.isEmpty) return loc.addProperty_required;
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            return emailRegex.hasMatch(value) ? null : loc.addProperty_invalidEmail;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              flex: 0,
              child: SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  value: _selectedCountryCode,
                  decoration: const InputDecoration(labelText: 'Código'),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCountryCode = newValue;
                      });
                    }
                  },
                  items: countryCodes.map((country) {
                    final display = '${country['flag']} ${country['code']}';
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Text(display, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _tenantPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.addProperty_step2_tenantPhone,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return loc.addProperty_required;
                  if (value.length < 6) return loc.addProperty_invalidPhone;
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(AppLocalizations loc) {
    return ListView(
      children: [
        Text(
          loc.addProperty_step3_contractFile,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        TextButton(
          onPressed: _pickContractFile,
          child: Text(_contractFilePath != null
              ? loc.addProperty_step3_fileSelected
              : loc.addProperty_step3_selectFile),
        ),
        const SizedBox(height: 16),
        Text(
          loc.addProperty_step3_initialPhotos,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        TextButton(
          onPressed: _pickInitialPhotos,
          child: Text(loc.addProperty_step3_selectPhotos),
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
