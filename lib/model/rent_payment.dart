import 'package:hive/hive.dart';

part 'rent_payment.g.dart';

@HiveType(typeId: 3)
class RentPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String? note;

  @HiveField(4)
  List<String> photoPaths; // antes era String? photoPath

  RentPayment({
    required this.id,
    required this.date,
    required this.amount,
    this.note,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? [];
}
