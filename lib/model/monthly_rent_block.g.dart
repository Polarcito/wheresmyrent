// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_rent_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyRentBlockAdapter extends TypeAdapter<MonthlyRentBlock> {
  @override
  final int typeId = 2;

  @override
  MonthlyRentBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyRentBlock(
      year: fields[0] as int,
      month: fields[1] as int,
      effectiveRent: fields[2] as double?,
      payments: (fields[3] as List?)?.cast<RentPayment>(),
      maintenanceEntries: (fields[4] as List?)?.cast<MaintenanceEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyRentBlock obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.effectiveRent)
      ..writeByte(3)
      ..write(obj.payments)
      ..writeByte(4)
      ..write(obj.maintenanceEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyRentBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
