import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheresmyrent/model/payment.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/screens/add_payment_screen.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wheresmyrent/model/generic/config.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _selectedYear = DateTime.now().year;
  late Property _currentProperty;

  @override
  void initState() {
    super.initState();
    _currentProperty = widget.property;
  }

  //actualiza la instancia de HIVE para poder ver los cambios que se realizan al objeto, esto ayuda a refrescar la UI
  Future<void> _reloadProperty() async {
    final box = Hive.box<Property>(Config.boxName);
    final updated = box.get(_currentProperty.id);
    if (updated != null) {
      setState(() {
        _currentProperty = updated;
      });
    }
  }

  void _deleteProperty() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${_currentProperty.name}" and all related data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      //Borrar archivo de contrato si existe
      if (_currentProperty.contractFilePath != null) {
        final contractFile = File(_currentProperty.contractFilePath!);
        if (await contractFile.exists()) await contractFile.delete();
      }

      //Borrar todas las fotos de pagos si existen
      for (final payment in _currentProperty.payments) {
        if (payment.photoPath != null) {
          final photoFile = File(payment.photoPath!);
          if (await photoFile.exists()) await photoFile.delete();
        }
      }

      //Eliminar la propiedad de Hive
      await _currentProperty.delete();

      //Volver a la pantalla anterior
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> pickContractFile(Property property) async {
    final typeGroup = XTypeGroup(
      label: 'Contratos',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final original = File(file.path);

      // Obtener carpeta interna segura
      final appDir = await getApplicationDocumentsDirectory();
      final contractsDir = Directory('${appDir.path}/contracts');

      // Crear carpeta si no existe
      if (!await contractsDir.exists()) {
        await contractsDir.create(recursive: true);
      }

      // Crear nuevo archivo con nombre único
      final fileName = path.basename(file.path); // nombre original
      final newPath = path.join(contractsDir.path, '${property.id}_$fileName');

      final savedFile = await original.copy(newPath);

      // Guardar la nueva ruta
      property.contractFilePath = savedFile.path;
      await property.save();
    }
  }

  void openContractFileIfExists(String path) {
    final file = File(path);
    if (file.existsSync()) {
      OpenFile.open(path);
    } else {
      print("Archivo no encontrado. Puede haber sido movido o eliminado.");
    }
  }

  Future<void> deleteContractFile(Property property) async {
    final path = property.contractFilePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      property.contractFilePath = null;
      await property.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProperty.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Property',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPropertyScreen(existingProperty: _currentProperty),
                ),
              );
              if (updated != null) await _reloadProperty();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Property',
            onPressed: _deleteProperty,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExpansionTile(
            title: Row(
              children: const [Text("Property Details")],
            ),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🏠 Property Info", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildDetailTile("Address", _currentProperty.address),
                    _buildDetailTile("Monthly Rent", "\$${_currentProperty.monthlyRent.toStringAsFixed(2)}"),
                    _buildDetailTile("Due Day", "Day ${_currentProperty.dueDay}"),
                    _buildDetailTile("Start Date", dateFormat.format(_currentProperty.startDate)),
                    if (_currentProperty.endDate != null)
                      _buildDetailTile("End Date", dateFormat.format(_currentProperty.endDate!)),
                    _buildDetailTile("Status", _currentProperty.isActive ? "Active" : "Inactive"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("👤 Tenant Info", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildDetailTile("Name", _currentProperty.tenantName),
                    _buildDetailTile("Email", _currentProperty.tenantEmail ?? ""),
                    _buildDetailTile("Phone", _currentProperty.tenantPhone ?? ""),
                  ],
                ),
              ),
              if (_currentProperty.contractFilePath != null) ...[
                ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text("Ver contrato"),
                  subtitle: Text(_currentProperty.contractFilePath!.split('/').last),
                  trailing: Icon(Icons.open_in_new),
                  onTap: () => openContractFileIfExists(_currentProperty.contractFilePath!),
                ),
                OverflowBar(
                  alignment: MainAxisAlignment.start,
                  spacing: 12.0, // Espacio horizontal entre botones
                  overflowSpacing: 8.0, // Espacio vertical cuando se hace wrap
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await pickContractFile(_currentProperty);
                        await _reloadProperty(); // <- esto reemplaza el setState
                      },
                      icon: Icon(Icons.upload_file),
                      label: Text("Reemplazar"),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("¿Eliminar contrato?"),
                            content: Text("Esta acción no se puede deshacer."),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar")),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await deleteContractFile(_currentProperty);
                          await _reloadProperty();
                        }
                      },
                      icon: Icon(Icons.delete),
                      label: Text("Eliminar"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ] else ...[
                ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text("Agregar contrato"),
                  onTap: () async {
                    await pickContractFile(_currentProperty);
                    await _reloadProperty();
                  }
                ),
              ]
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Payments", style: Theme.of(context).textTheme.titleLarge),
              DropdownButton<int>(
                value: _selectedYear,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedYear = value);
                  }
                },
                items: List.generate(5, (i) {
                  final year = DateTime.now().year - i;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final month = index + 1;
              Payment? paidPayment;
              try {
                paidPayment = _currentProperty.payments.firstWhere(
                  (p) => p.date.month == month && p.date.year == _selectedYear && p.isPaid,
                );
              } catch (_) {
                paidPayment = null;
              }

              final paid = paidPayment != null;
              final hasPhoto = paidPayment?.photoPath?.isNotEmpty == true;
              final monthName = DateFormat.MMM().format(DateTime(0, month));

              return InkWell(
                onTap: () async {
                  final paymentDate = DateTime(_selectedYear, month, _currentProperty.dueDay);
                  if (paidPayment != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Payment - $monthName $_selectedYear"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📅 Date: ${DateFormat.yMMMd().format(paidPayment!.date)}"),
                              const SizedBox(height: 8),
                              Text("📝 Comment: ${paidPayment.comment?.isNotEmpty == true ? paidPayment.comment! : "No comment"}"),
                              const SizedBox(height: 12),
                              if (hasPhoto)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        child: Image.file(File(paidPayment!.photoPath!)),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("📸 Photo:"),
                                      const SizedBox(height: 4),
                                      Image.file(
                                        File(paidPayment!.photoPath!),
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Text("📸 No photo uploaded."),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPaymentScreen(
                                      property: _currentProperty,
                                      preselectedDate: paymentDate,
                                    ),
                                  ),
                                );
                                await _reloadProperty();
                              },
                              child: const Text("Edit"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  final removed = _currentProperty.payments.firstWhere(
                                    (p) => p.date.month == month && p.date.year == _selectedYear,
                                  );

                                  //Borra la foto asociada si existe
                                  if (removed.photoPath != null) {
                                    final file = File(removed.photoPath!);
                                    if (file.existsSync()) {
                                      file.delete();
                                    }
                                  }

                                  _currentProperty.payments.remove(removed);
                                  _currentProperty.save();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPaymentScreen(
                          property: _currentProperty,
                          preselectedDate: paymentDate,
                        ),
                      ),
                    );
                    await _reloadProperty();
                  }
                },
                onLongPress: paid
                    ? () async {
                        final paymentDate = DateTime(_selectedYear, month, _currentProperty.dueDay);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddPaymentScreen(
                              property: _currentProperty,
                              preselectedDate: paymentDate,
                            ),
                          ),
                        );
                        await _reloadProperty();
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: paid ? AppColors.success : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: paid ? AppColors.success : Colors.grey.shade600),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(monthName, style: TextStyle(fontWeight: FontWeight.bold, color: paid ? Colors.white : Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Icon(
                              paid ? Icons.check_circle : Icons.cancel,
                              color: paid ? Colors.white : Colors.grey.shade700,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      if (hasPhoto)
                        const Positioned(
                          bottom: 4,
                          right: 4,
                          child: Icon(Icons.image, size: 18, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
