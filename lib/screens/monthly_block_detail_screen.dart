import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/model/maintenance_entry.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/rent_payment.dart';

class MonthlyBlockDetailScreen extends StatefulWidget {
  final Property property;
  final MonthlyRentBlock block;

  const MonthlyBlockDetailScreen({
    super.key,
    required this.property,
    required this.block,
  });

  @override
  State<MonthlyBlockDetailScreen> createState() => _MonthlyBlockDetailScreenState();
}

class _MonthlyBlockDetailScreenState extends State<MonthlyBlockDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final String monthLabel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    monthLabel = DateFormat.MMMM('es').format(DateTime(widget.block.year, widget.block.month));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${monthLabel[0].toUpperCase()}${monthLabel.substring(1)} ${widget.block.year}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Resumen'),
            Tab(icon: Icon(Icons.payments), text: 'Pagos'),
            Tab(icon: Icon(Icons.build), text: 'Mantención'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResumenTab(),
          _buildPagosTab(),
          _buildMantencionTab(),
        ],
      ),
    );
  }

  Widget _buildResumenTab() {
    final totalPagado = widget.block.payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    final totalMantencion = widget.block.maintenanceEntries.fold<double>(0.0, (sum, m) => sum + m.amount);
    final montoEsperado = widget.block.effectiveRent;
    final faltaPorPagar = (montoEsperado - totalPagado).clamp(0, double.infinity).toDouble();
    final excedente = (totalPagado - montoEsperado).clamp(0, double.infinity).toDouble();
    final balanceFinal = totalPagado - montoEsperado + totalMantencion;

    final dataMap = <String, double>{
      if (totalPagado > 0) "Pagado": totalPagado > montoEsperado ? montoEsperado : totalPagado,
      if (faltaPorPagar > 0) "Faltante": faltaPorPagar,
      if (excedente > 0) "Excedente": excedente,
      if (totalMantencion > 0) "Mantención": totalMantencion,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: PieChart(
              dataMap: dataMap,
              chartRadius: 180,
              chartType: ChartType.disc,
              ringStrokeWidth: 32,
              legendOptions: const LegendOptions(showLegends: true),
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValueBackground: false,
                decimalPlaces: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildResumenEffectiveRentRow(
            "Monto esperado de arriendo:",
            '\$${montoEsperado.toStringAsFixed(0)}',
            _showEditRentDialog,
          ),
          _buildResumenRow("Total pagado:", '\$${totalPagado.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildResumenRow("Faltante por pagar:", '\$${faltaPorPagar.toStringAsFixed(0)}',
              color: Colors.red),
          const SizedBox(height: 8),
          _buildResumenRow("Excedente:", '\$${excedente.toStringAsFixed(0)}',
              color: Colors.green),
          const Divider(height: 32),
          _buildResumenRow("Gastos de mantención:", '\$${totalMantencion.toStringAsFixed(0)}',
              color: Colors.orange),
          const Divider(height: 32),
          _buildResumenRow(
            "Balance final:",
            '\$${balanceFinal.toStringAsFixed(0)}',
            color: balanceFinal >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddPaymentSheet,
                icon: const Icon(Icons.payments),
                label: const Text(
                  "Ingresar pago",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddMaintenanceSheet,
                icon: const Icon(Icons.build_circle),
                label: const Text(
                  "Ingresar mantención",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildResumenEffectiveRentRow(String label, String value, VoidCallback onEdit, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Editar monto esperado',
                onPressed: onEdit,
                padding: const EdgeInsets.only(left: 4),
                constraints: const BoxConstraints(),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagosTab() {
    final payments = widget.block.payments;

    return Stack(
      children: [
        if (payments.isEmpty)
          const Center(
            child: Text(
              "Sin pagos registrados",
              style: TextStyle(fontSize: 16),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.attach_money, color: Colors.green),
                  title: Text(
                    '\$${p.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat.yMMMd('es').format(p.date)),
                      if (p.note != null) Text(p.note!),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (p.photoPaths.isNotEmpty)
                        const Icon(Icons.image, size: 20, color: Colors.grey),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddPaymentSheet(
                          existingPayment: p,
                          onSave: (updated) {
                            setState(() {
                              payments[index] = updated;
                              widget.property.save();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePayment(p),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (p.photoPaths.isNotEmpty) {
                      _showImageGallery(p.photoPaths);
                    }
                  },
                ),
              );
            },
          ),

        // FAB siempre visible
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showAddPaymentSheet,
            child: const Icon(Icons.add),
            tooltip: 'Ingresar pago',
          ),
        ),
      ],
    );
  }

  Widget _buildMantencionTab() {
    final entries = widget.block.maintenanceEntries;

    return Stack(
      children: [
        if (entries.isEmpty)
          const Center(
            child: Text(
              "Sin registros de mantención",
              style: TextStyle(fontSize: 16),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final m = entries[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.build_circle,
                    color: m.amount >= 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    '\$${m.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: m.amount >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.description),
                      Text(
                        DateFormat.yMMMd('es').format(m.date),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (m.photoPaths.isNotEmpty)
                        const Icon(Icons.image, size: 20, color: Colors.grey),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddMaintenanceSheet(
                          existingEntry: m,
                          onSave: (updated) {
                            setState(() {
                              entries[index] = updated;
                              widget.property.save();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMaintenance(m),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (m.photoPaths.isNotEmpty) {
                      _showImageGallery(m.photoPaths);
                    }
                  },
                ),
              );
            },
          ),

        // FAB siempre visible
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showAddMaintenanceSheet,
            child: const Icon(Icons.add),
            tooltip: 'Agregar mantención',
          ),
        ),
      ],
    );
  }

  void _showAddPaymentSheet({
    RentPayment? existingPayment,
    void Function(RentPayment)? onSave,
  }) {
    final amountController = TextEditingController(
        text: existingPayment?.amount.toStringAsFixed(0) ?? '');
    final noteController =
        TextEditingController(text: existingPayment?.note ?? '');
    DateTime selectedDate = existingPayment?.date ?? DateTime.now();
    List<String> selectedPhotos = List.from(existingPayment?.photoPaths ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingPayment != null ? 'Editar pago' : 'Ingresar pago',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    decoration: const InputDecoration(labelText: 'Monto'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Nota'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Fecha:'),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text(DateFormat.yMMMd('es').format(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setModalState(() {
                              selectedPhotos.addAll(images.map((e) => e.path));
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image =
                              await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setModalState(() {
                              selectedPhotos.add(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedPhotos.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedPhotos
                          .map((path) => Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullScreenImage(path),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedPhotos.remove(path);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final amount = double.tryParse(
                              amountController.text.replaceAll(',', '.')) ??
                          0;

                      if (amount <= 0) return;

                      final updatedPayment = RentPayment(
                        id: existingPayment?.id ?? UniqueKey().toString(),
                        amount: amount,
                        date: selectedDate,
                        note: noteController.text.trim(),
                        photoPaths: selectedPhotos,
                      );

                      if (onSave != null) {
                        onSave(updatedPayment);
                      } else {
                        setState(() {
                          widget.block.payments.add(updatedPayment);
                          widget.property.save();
                        });
                      }

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar pago'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddMaintenanceSheet({
    MaintenanceEntry? existingEntry,
    void Function(MaintenanceEntry)? onSave,
  }) {
    final descriptionController = TextEditingController(
      text: existingEntry?.description ?? '',
    );
    final amountController = TextEditingController(
      text: existingEntry?.amount.toString() ?? '',
    );
    DateTime selectedDate = existingEntry?.date ?? DateTime.now();
    List<String> selectedPhotos = List.from(existingEntry?.photoPaths ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingEntry != null
                        ? 'Editar mantención'
                        : 'Ingresar mantención',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Monto (+ ingreso, – gasto)'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Fecha:'),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Text(DateFormat.yMMMd('es').format(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            setModalState(() {
                              selectedPhotos.addAll(images.map((e) => e.path));
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galería'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image =
                              await picker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setModalState(() => selectedPhotos.add(image.path));
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedPhotos.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedPhotos
                          .map((path) => Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFullScreenImage(path),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(path),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedPhotos.remove(path);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final amount = double.tryParse(
                            amountController.text.replaceAll(',', '.'),
                          ) ??
                          0;
                      final description = descriptionController.text.trim();

                      if (description.isEmpty || amount == 0) return;

                      final entry = MaintenanceEntry(
                        id: existingEntry?.id ?? UniqueKey().toString(),
                        description: description,
                        amount: amount,
                        date: selectedDate,
                        photoPaths: selectedPhotos,
                      );

                      if (onSave != null) {
                        onSave(entry);
                      } else {
                        setState(() {
                          widget.block.maintenanceEntries.add(entry);
                          widget.property.save();
                        });
                      }

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar mantención'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.file(File(imagePath)),
          ),
        ),
      ),
    );
  }

  void _deletePayment(RentPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar pago?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.block.payments.removeWhere((p) => p.id == payment.id);
                widget.property.save(); // Persistir
              });
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteMaintenance(MaintenanceEntry m) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro de mantención?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.block.maintenanceEntries.remove(m);
                widget.property.save();
              });
              Navigator.pop(context);
            },
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(List<String> photoPaths) {
    int currentIndex = 0;
    final pageController = PageController(initialPage: currentIndex);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 500, maxWidth: 350),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: photoPaths.length,
                      onPageChanged: (index) {
                        setState(() => currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: InteractiveViewer(
                            child: Image.file(
                              File(photoPaths[index]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                    // Flecha izquierda
                    if (photoPaths.length > 1)
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () {
                            if (currentIndex > 0) {
                              currentIndex--;
                              pageController.animateToPage(
                                currentIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    // Flecha derecha
                    if (photoPaths.length > 1)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () {
                            if (currentIndex < photoPaths.length - 1) {
                              currentIndex++;
                              pageController.animateToPage(
                                currentIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    // Contador
                    if (photoPaths.length > 1)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${photoPaths.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditRentDialog() {
    final controller = TextEditingController(text: widget.block.effectiveRent.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar monto esperado'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nuevo monto',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRent = double.tryParse(controller.text);
              if (newRent != null) {
                setState(() {
                  widget.block.effectiveRent = newRent;
                  widget.property.save(); // Guarda en Hive
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}