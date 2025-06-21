import 'payment.dart';

class Property {
  final String id;
  final String name;
  final String address;
  final String tenantName;
  final double monthlyRent;
  final int dueDay; // día del mes en que vence el pago
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  final String? contractFilePath;
  final List<String> initialPhotos; // paths locales de imágenes

  final List<Payment> payments;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.tenantName,
    required this.monthlyRent,
    required this.dueDay,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.contractFilePath,
    this.initialPhotos = const [],
    this.payments = const [],
  });

  bool get hasPendingPayment {
    final now = DateTime.now();
    return payments.every((p) =>
        !(p.date.month == now.month &&
          p.date.year == now.year &&
          p.isPaid));
  }
}
