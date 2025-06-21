import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheresmyrent/model/payment.dart';
import 'package:wheresmyrent/model/property.dart';
import 'package:wheresmyrent/model/generic/app_colors.dart';
import 'package:wheresmyrent/screens/add_payment_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailTile("Address", widget.property.address),
          _buildDetailTile("Tenant", widget.property.tenantName),
          _buildDetailTile("Monthly Rent", "\$${widget.property.monthlyRent.toStringAsFixed(2)}"),
          _buildDetailTile("Due Day", "Day ${widget.property.dueDay}"),
          _buildDetailTile("Start Date", dateFormat.format(widget.property.startDate)),
          if (widget.property.endDate != null)
            _buildDetailTile("End Date", dateFormat.format(widget.property.endDate!)),
          _buildDetailTile("Status", widget.property.isActive ? "Active" : "Inactive"),
          const Divider(height: 32),
          Text("Payments", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (widget.property.payments.isEmpty)
            const Text("No payments recorded."),
          ...widget.property.payments.map((p) => ListTile(
                title: Text(DateFormat.yMMMd().format(p.date)),
                subtitle: Text(p.comment ?? ''),
                trailing: p.isPaid
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : const Icon(Icons.warning, color: AppColors.warning),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPaymentScreen(property: widget.property),
            ),
          );
          setState(() {}); // Refresca la UI después de volver
        },
        icon: const Icon(Icons.attach_money),
        label: const Text("Add Payment"),
        backgroundColor: AppColors.secondary,
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
