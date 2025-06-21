import 'package:hive/hive.dart';
import 'payment.dart';

part 'property.g.dart';

@HiveType(typeId: 0)
class Property extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String tenantName;

  @HiveField(4)
  final double monthlyRent;

  @HiveField(5)
  final int dueDay;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime? endDate;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final String? contractFilePath;

  @HiveField(10)
  final List<String> initialPhotos;

  @HiveField(11)
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
    List<String>? initialPhotos,
    List<Payment>? payments,
  })  : initialPhotos = initialPhotos ?? [],
        payments = payments ?? [];


  bool get hasPendingPayment {
    final now = DateTime.now();
    return payments.every((p) =>
        !(p.date.month == now.month &&
          p.date.year == now.year &&
          p.isPaid));
  }
}
