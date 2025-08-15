import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:wheresmyrent/model/generic/currency_helper.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/screens/monthly_block_detail_screen.dart';
import 'package:wheresmyrent/gen_l10n/app_localizations.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();

    final p = widget.property;
    final monthlyRent = p.monthlyRent;

    final currentYearBlocks = p.monthlyBlocks
        .where((b) => b.year == selectedYear)
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: loc.propertyDetails_tooltip, // "Ver detalles"
            onPressed: _showPropertyDetailsModal,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: loc.common_edit, // "Editar propiedad"
            onPressed: () async {
              final originalRent = p.monthlyRent;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPropertyScreen(existingProperty: p),
                ),
              );
              if (mounted) {
                setState(() {});
                if (p.monthlyRent != originalRent) {
                  await _mostrarDialogoActualizarRenta(context, p, originalRent);
                }
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(5),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYearSelector(loc),
                const SizedBox(height: 8),
                _buildMonthlyGrid(currentYearBlocks, monthlyRent, localeName, loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector(AppLocalizations loc) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          loc.year_label, // "Año:"
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: selectedYear,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedYear = value);
            }
          },
          items: List.generate(10, (i) {
            final year = DateTime.now().year - 5 + i;
            return DropdownMenuItem(
              value: year,
              child: Text(
                year.toString(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }

  void _ensureBlocksForYear(int year) {
    final existingMonths = widget.property.monthlyBlocks
        .where((b) => b.year == year)
        .map((b) => b.month)
        .toSet();

    final missingMonths = List.generate(12, (i) => i + 1)
        .where((month) => !existingMonths.contains(month));

    if (missingMonths.isNotEmpty) {
      for (final month in missingMonths) {
        widget.property.monthlyBlocks.add(
          MonthlyRentBlock(
            year: year,
            month: month,
            effectiveRent: widget.property.monthlyRent,
          ),
        );
      }
      widget.property.save();
    }
  }

  Widget _buildMonthlyGrid(
    List blocks,
    double monthlyRent,
    String localeName,
    AppLocalizations loc,
  ) {
    _ensureBlocksForYear(selectedYear);

    final sortedBlocks = widget.property.monthlyBlocks
        .where((b) => b.year == selectedYear)
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return GridView.builder(
      itemCount: sortedBlocks.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final block = sortedBlocks[index];
        final total = block.payments.fold(0.0, (sum, p) => sum + p.amount);

        // Mes en el idioma actual
        final monthName = DateFormat.MMM(localeName).format(DateTime(0, block.month));

        final DateTime today = DateTime.now();
        final DateTime dueDate = DateTime(block.year, block.month, widget.property.dueDay);
        final DateTime contractStart = widget.property.startDate;

        final bool isBeforeContract =
            DateTime(block.year, block.month).isBefore(DateTime(contractStart.year, contractStart.month));
        final bool isFuture = dueDate.isAfter(today);
        final bool isPaid = total >= block.effectiveRent;
        final bool isPartial = total > 0 && total < block.effectiveRent;
        final bool isUnpaid = total == 0 && !isFuture;

        IconData icon;
        Color color;

        if (isBeforeContract) {
          icon = Icons.history;
          color = Colors.grey;
        } else if (isPaid) {
          icon = Icons.check_circle;
          color = Colors.green;
        } else if (isPartial) {
          icon = Icons.hourglass_bottom;
          color = Colors.orange;
        } else if (isUnpaid) {
          icon = Icons.cancel;
          color = Colors.red;
        } else {
          icon = Icons.calendar_today;
          color = Colors.blueGrey;
        }

        final double percentPaid = (total / block.effectiveRent).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonthlyBlockDetailScreen(
                  property: widget.property,
                  block: block,
                ),
              ),
            );
            setState(() {});
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: isBeforeContract ? Colors.grey.shade200 : null,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthName.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBeforeContract ? Colors.grey : null,
                        ),
                      ),
                      Icon(icon, color: color, size: 30),
                      Text(
                        '${(total / block.effectiveRent * 100).clamp(0, 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      LinearProgressIndicator(
                        value: percentPaid,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                ),
                if (block.maintenanceEntries.isNotEmpty)
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.build, size: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPropertyDetailsModal() {
    final loc = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final p = widget.property;

    final formatter = DateFormat.yMMMd(localeName);
    final hasContract = p.contractFilePath != null && File(p.contractFilePath!).existsSync();
    final hasPhotos = p.initialPhotos.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.propertyDetails_title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('🏠 ${loc.propertyDetails_tenantName(p.tenantName)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('✉️ ${loc.propertyDetails_tenantEmail(p.tenantEmail)}'),
              Text('📞 ${loc.propertyDetails_tenantPhone("${p.tenantPhoneCode} ${p.tenantPhoneNumber}")}'),
              const SizedBox(height: 8),
              Text('📍 ${loc.propertyDetails_address(p.address)}'),
              Text('💵 ${loc.propertyDetails_monthlyRent(formatAmountWithCurrencySync(context, p.monthlyRent))}'),
              Text('📆 ${loc.propertyDetails_dueDay(p.dueDay)}'),
              Text('⏳ ${loc.propertyDetails_startDate(formatter.format(p.startDate))}'),
              if (p.endDate != null)
                Text('🏁 ${loc.propertyDetails_endDate(formatter.format(p.endDate!))}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (hasContract)
                    TextButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(loc.propertyDetails_viewContract),
                      onPressed: () => OpenFile.open(p.contractFilePath!),
                    ),
                  if (hasPhotos)
                    TextButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(loc.propertyDetails_viewPhotos),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: p.initialPhotos
                                    .map((path) => Image.file(
                                          File(path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoActualizarRenta(
      BuildContext context, Property propiedad, double valorAnterior) async {
    final loc = AppLocalizations.of(context)!;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.updateRent_title), // "¿Aplicar nuevo arriendo?"
        content: Text(
          loc.updateRent_body(
            formatAmountWithCurrencySync(context, valorAnterior),
            formatAmountWithCurrencySync(context, propiedad.monthlyRent),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.common_no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.common_yes),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final hoy = DateTime.now();
      for (final block in propiedad.monthlyBlocks) {
        final fechaBloque = DateTime(block.year, block.month, propiedad.dueDay);
        if (fechaBloque.isAfter(hoy)) {
          block.effectiveRent = propiedad.monthlyRent;
        }
      }

      await propiedad.save();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.updateRent_appliedSnack)), // "Nuevo arriendo aplicado..."
        );
      }
      setState(() {});
    }
  }
}
