import 'package:hive/hive.dart';
import 'package:wheresmyrent/model/monthly_rent_block.dart';

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
  String tenantEmail;

  @HiveField(5)
  String tenantPhone;

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
  List<MonthlyRentBlock> monthlyBlocks;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.monthlyRent,
    required this.dueDay,
    required this.startDate,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
    this.endDate,
    this.isActive = true,
    this.contractFilePath,
    List<String>? initialPhotos,
    List<MonthlyRentBlock>? monthlyBlocks,
  })  : initialPhotos = initialPhotos ?? [],
        monthlyBlocks = monthlyBlocks ?? _generateInitialBlocks(startDate, monthlyRent);

  static List<MonthlyRentBlock> _generateInitialBlocks(DateTime startDate, double monthlyRent) {
    final List<MonthlyRentBlock> blocks = [];
    final int year = DateTime.now().year;

    for (int month = 1; month <= 12; month++) {
      blocks.add(MonthlyRentBlock(year: year, month: month, effectiveRent: monthlyRent));
    }

    return blocks;
  }
}
