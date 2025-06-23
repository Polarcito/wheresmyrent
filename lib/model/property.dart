import 'package:hive/hive.dart';
import 'payment.dart';

part 'property.g.dart';

@HiveType(typeId: 0)
class Property extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  String tenantName;

  @HiveField(4)
  String? tenantEmail;

  @HiveField(5)
  String? tenantPhone;

  @HiveField(6)
  double monthlyRent;

  @HiveField(7)
  int dueDay;

  @HiveField(8)
  DateTime startDate;

  @HiveField(9)
  DateTime? endDate;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  String? contractFilePath;

  @HiveField(12)
  List<String> initialPhotos;

  @HiveField(13)
  List<Payment> payments;

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
    this.tenantEmail,
    this.tenantPhone,
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
