import 'package:hive/hive.dart';

part 'maintenance_entry.g.dart'; // ✅ asegúrate que el archivo se llama así

@HiveType(typeId: 4)
class MaintenanceEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount; // Puede ser positivo o negativo

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  List<String> photoPaths; // ✅ ahora puede manejar varias fotos

  MaintenanceEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? [];
}
