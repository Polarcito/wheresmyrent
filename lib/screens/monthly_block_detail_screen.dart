import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';
import 'package:wheresmyrent/model/generic/app_theme.dart';
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
          tabs: [
            Tab(icon: Icon(Icons.analytics), text: AppLocalizations.of(context)!.tab_summary),
            Tab(icon: Icon(Icons.payments), text: AppLocalizations.of(context)!.tab_payments),
            Tab(icon: Icon(Icons.build), text: AppLocalizations.of(context)!.tab_maintenance),
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
      if (totalPagado > 0)
        AppLocalizations.of(context)!.summary_paid: totalPagado > montoEsperado ? montoEsperado : totalPagado,
      if (faltaPorPagar > 0)
        AppLocalizations.of(context)!.summary_missing: faltaPorPagar,
      if (excedente > 0)
        AppLocalizations.of(context)!.summary_excess: excedente,
      if (totalMantencion > 0)
        AppLocalizations.of(context)!.summary_maintenance: totalMantencion,
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
              legendOptions: LegendOptions(showLegends: true, legendTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
              chartValuesOptions: ChartValuesOptions(
                showChartValuesInPercentage: true,
                showChartValueBackground: false,
                decimalPlaces: 0,
                chartValueStyle: TextStyle(color: Theme.of(context).colorScheme.surface)
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildResumenEffectiveRentRow(
            AppLocalizations.of(context)!.summary_expectedRent,
            '\$${montoEsperado.toStringAsFixed(0)}',
            _showEditRentDialog,
          ),
          _buildResumenRow(
            AppLocalizations.of(context)!.summary_totalPaid,
            '\$${totalPagado.toStringAsFixed(0)}',
          ),
          _buildResumenRow(
            AppLocalizations.of(context)!.summary_amountDue,
            '\$${faltaPorPagar.toStringAsFixed(0)}',
            color: Colors.red,
          ),
          _buildResumenRow(
            AppLocalizations.of(context)!.summary_overpayment,
            '\$${excedente.toStringAsFixed(0)}',
            color: Colors.green,
          ),
          _buildResumenRow(
            AppLocalizations.of(context)!.summary_maintenanceCosts,
            '\$${totalMantencion.toStringAsFixed(0)}',
            color: Colors.orange,
          ),
          _buildResumenRow(
            AppLocalizations.of(context)!.summary_finalBalance,
            '\$${balanceFinal.toStringAsFixed(0)}',
            color: balanceFinal >= 0 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddPaymentSheet,
                  icon: const Icon(Icons.payments),
                  label: Text(AppLocalizations.of(context)!.summary_addPayment),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddMaintenanceSheet,
                  icon: const Icon(Icons.build_circle),
                  label: Text(AppLocalizations.of(context)!.summary_addMaintenance),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary,),),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary,),),
      ],
    );
  }

  Widget _buildResumenEffectiveRentRow(String label, String value, VoidCallback onEdit, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary,),)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: Theme.of(context).colorScheme.primary,),
                tooltip: AppLocalizations.of(context)!.summary_editExpectedRent,
                onPressed: onEdit,
                padding: const EdgeInsets.only(left: 4),
                constraints: const BoxConstraints(),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary,),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagosTab() {
    final payments = widget.block.payments;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        if (payments.isEmpty)
          Center(
            child: Text(
              AppLocalizations.of(context)!.payments_noPayments,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                color: colorScheme.surface,
                shadowColor: theme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (p.photoPaths.isNotEmpty) {
                      _showImageGallery(p.photoPaths);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${p.amount.toStringAsFixed(0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMd('es').format(p.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                              if (p.note != null)
                                Text(
                                  p.note!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            if (p.photoPaths.isNotEmpty)
                              Icon(Icons.image, size: 20, color: colorScheme.secondary),
                            IconButton(
                              icon: Icon(Icons.edit, color: colorScheme.primary),
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
                              icon: Icon(Icons.delete, color: colorScheme.error),
                              onPressed: () => _deletePayment(p),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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
            tooltip: AppLocalizations.of(context)!.payments_addPayment,
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.add, color: colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildMantencionTab() {
    final entries = widget.block.maintenanceEntries;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        if (entries.isEmpty)
          Center(
            child: Text(
              AppLocalizations.of(context)!.maintenance_noEntries,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final m = entries[index];
              final isPositive = m.amount >= 0;
              final amountColor = isPositive ? Colors.green.shade600 : Colors.red.shade600;
              final avatarBg = isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                color: colorScheme.surface,
                shadowColor: theme.shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (m.photoPaths.isNotEmpty) {
                      _showImageGallery(m.photoPaths);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: avatarBg,
                          child: Icon(
                            Icons.build_circle,
                            color: amountColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${m.amount.toStringAsFixed(0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: amountColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd('es').format(m.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            if (m.photoPaths.isNotEmpty)
                              Icon(Icons.image, size: 20, color: colorScheme.outline),
                            IconButton(
                              icon: Icon(Icons.edit, color: colorScheme.primary),
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
                              icon: Icon(Icons.delete, color: colorScheme.error),
                              onPressed: () => _deleteMaintenance(m),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showAddMaintenanceSheet,
            tooltip: AppLocalizations.of(context)!.maintenance_addEntry,
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.add, color: colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  void _showAddPaymentSheet({
  RentPayment? existingPayment,
  void Function(RentPayment)? onSave,
  }) {
    final loc = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
        text: existingPayment?.amount.toStringAsFixed(0) ?? '');
    final noteController = TextEditingController(text: existingPayment?.note ?? '');
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
                    existingPayment != null
                        ? loc.payment_edit
                        : loc.payment_add,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: false, decimal: true),
                    decoration: InputDecoration(labelText: loc.payment_amountLabel),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(labelText: loc.payment_noteLabel),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        loc.payment_dateLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                            ),
                      ),
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
                        child: Text(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          label: Text(loc.payment_galleryButton),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.camera);
                            if (image != null) {
                              setModalState(() {
                                selectedPhotos.add(image.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: Text(loc.payment_cameraButton),
                        ),
                      ],
                    ),
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
                    label: Text(loc.payment_saveButton),
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
    final loc = AppLocalizations.of(context)!;
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
                        ? loc.maintenance_edit
                        : loc.maintenance_add,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: loc.maintenance_descriptionLabel),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    decoration: InputDecoration(
                        labelText: loc.maintenance_amountLabel),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        loc.maintenance_dateLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                            ),
                      ),
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
                        child: Text(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          label: Text(loc.maintenance_galleryButton),
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
                          label: Text(loc.maintenance_cameraButton),
                        ),
                      ],
                    ),
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
                    label: Text(loc.maintenance_saveButton),
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
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.payment_deleteTitle),
        content: Text(loc.payment_deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.payment_cancelButton),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.block.payments.removeWhere((p) => p.id == payment.id);
                widget.property.save(); // Persistir
              });
              Navigator.pop(context);
            },
            child: Text(
              loc.payment_confirmDeleteButton,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMaintenance(MaintenanceEntry m) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.maintenance_deleteTitle),
        content: Text(loc.maintenance_deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.maintenance_cancelButton),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.block.maintenanceEntries.remove(m);
                widget.property.save();
              });
              Navigator.pop(context);
            },
            child: Text(
              loc.maintenance_confirmDeleteButton,
              style: const TextStyle(color: Colors.red),
            ),
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
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.block.effectiveRent.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.editRentDialog_title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.editRentDialog_label,
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.common_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newRent = double.tryParse(controller.text);
              if (newRent != null) {
                setState(() {
                  widget.block.effectiveRent = newRent;
                  widget.property.save();
                });
                Navigator.pop(context);
              }
            },
            child: Text(loc.common_save),
          ),
        ],
      ),
    );
  }
}