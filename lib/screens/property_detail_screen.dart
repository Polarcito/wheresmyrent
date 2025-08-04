import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/screens/add_property_screen.dart';
import 'package:wheresmyrent/screens/monthly_block_detail_screen.dart';

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
            tooltip: 'Ver detalles',
            onPressed: _showPropertyDetailsModal,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar propiedad',
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

                // Compara si el valor cambió
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
                _buildYearSelector(),
                const SizedBox(height: 8),
                _buildMonthlyGrid(currentYearBlocks, monthlyRent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      children: [
        Text(
          'Año:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: selectedYear,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedYear = value;
              });
            }
          },
          items: List.generate(10, (i) {
            final year = DateTime.now().year - 5 + i;
            return DropdownMenuItem(
              value: year,
              child: Text(
                year.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.primary,
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
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

  Widget _buildMonthlyGrid(List blocks, double monthlyRent) {
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
        final monthName = DateFormat.MMM('es').format(DateTime(0, block.month));

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
          icon = Icons.history; // antes del inicio
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
    final p = widget.property;
    final formatter = DateFormat.yMMMd('es');
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
              Text('Información de la propiedad', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('🏠 Arrendatario: ${p.tenantName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('✉️ Correo: ${p.tenantEmail}'),
              Text('📞 Teléfono: ${p.tenantPhone}'),
              const SizedBox(height: 8),
              Text('📍 Dirección: ${p.address}'),
              Text('💵 Arriendo mensual: \$${p.monthlyRent.toStringAsFixed(0)}'),
              Text('📆 Día de vencimiento: ${p.dueDay}'),
              Text('⏳ Inicio contrato: ${formatter.format(p.startDate)}'),
              if (p.endDate != null)
                Text('🏁 Fin contrato: ${formatter.format(p.endDate!)}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (hasContract)
                    TextButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Ver contrato'),
                      onPressed: () => OpenFile.open(p.contractFilePath!),
                    ),
                  if (hasPhotos)
                    TextButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Ver fotos'),
                      onPressed: () {
                        Navigator.of(context).pop(); // cerrar modal antes de abrir otro
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

  Future<void> _mostrarDialogoActualizarRenta(BuildContext context, Property propiedad, double valorAnterior) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Aplicar nuevo arriendo?"),
        content: Text(
          "Has cambiado el valor del arriendo de \$${valorAnterior.toStringAsFixed(0)} a \$${propiedad.monthlyRent.toStringAsFixed(0)}.\n\n"
          "¿Deseas aplicar este nuevo valor a los meses futuros que aún no están en fecha de pago?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí"),
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
          const SnackBar(content: Text("Nuevo arriendo aplicado a los meses futuros.")),
        );
      }
      setState(() {});
    }
  }
}
