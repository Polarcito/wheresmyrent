import 'package:hive/hive.dart';
import 'package:wheresmyrent/model/maintenance_entry.dart';
import 'package:wheresmyrent/model/rent_payment.dart';

part 'monthly_rent_block.g.dart';

@HiveType(typeId: 2)
class MonthlyRentBlock extends HiveObject {
  @HiveField(0)
  int year;

  @HiveField(1)
  int month;

  @HiveField(2)
  double effectiveRent;

  @HiveField(3)
  List<RentPayment> payments;

  @HiveField(4)
  List<MaintenanceEntry> maintenanceEntries;

  MonthlyRentBlock({
    required this.year,
    required this.month,
    double? effectiveRent,
    List<RentPayment>? payments,
    List<MaintenanceEntry>? maintenanceEntries,
  }) : payments = payments ?? [],
       maintenanceEntries = maintenanceEntries ?? [],
       effectiveRent = effectiveRent ?? 0;
}

extension RentBlockStatus on MonthlyRentBlock {
  String getPaymentStatus() {
    if (payments.isEmpty) return 'unpaid';

    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
    if (totalPaid >= effectiveRent) {
      return 'paid';
    } else if (totalPaid > 0) {
      return 'partial';
    } else {
      return 'unpaid';
    }
  }
}
