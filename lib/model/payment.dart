import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 1)
class Payment {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final bool isPaid;
  
  @HiveField(2)
  final String? photoPath; // comprobante [foto]

  @HiveField(3)
  final String? comment;

  Payment({
    required this.date,
    this.isPaid = false,
    this.photoPath,
    required this.comment,
  });
}
