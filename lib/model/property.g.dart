// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyAdapter extends TypeAdapter<Property> {
  @override
  final int typeId = 0;

  @override
  Property read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Property(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      tenantName: fields[3] as String,
      monthlyRent: fields[4] as double,
      dueDay: fields[5] as int,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime?,
      isActive: fields[8] as bool,
      contractFilePath: fields[9] as String?,
      initialPhotos: (fields[10] as List?)?.cast<String>(),
      payments: (fields[11] as List?)?.cast<Payment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.tenantName)
      ..writeByte(4)
      ..write(obj.monthlyRent)
      ..writeByte(5)
      ..write(obj.dueDay)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.contractFilePath)
      ..writeByte(10)
      ..write(obj.initialPhotos)
      ..writeByte(11)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
