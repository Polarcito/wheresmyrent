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
      monthlyRent: fields[6] as double,
      dueDay: fields[7] as int,
      startDate: fields[8] as DateTime,
      tenantName: fields[3] as String,
      tenantEmail: fields[4] as String,
      tenantPhone: fields[5] as String,
      endDate: fields[9] as DateTime?,
      isActive: fields[10] as bool,
      contractFilePath: fields[11] as String?,
      initialPhotos: (fields[12] as List?)?.cast<String>(),
      monthlyBlocks: (fields[13] as List?)?.cast<MonthlyRentBlock>(),
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.tenantName)
      ..writeByte(4)
      ..write(obj.tenantEmail)
      ..writeByte(5)
      ..write(obj.tenantPhone)
      ..writeByte(6)
      ..write(obj.monthlyRent)
      ..writeByte(7)
      ..write(obj.dueDay)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.contractFilePath)
      ..writeByte(12)
      ..write(obj.initialPhotos)
      ..writeByte(13)
      ..write(obj.monthlyBlocks);
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
