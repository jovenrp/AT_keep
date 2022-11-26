// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stocks_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockModelAdapter extends TypeAdapter<StockModel> {
  @override
  final int typeId = 0;

  @override
  StockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      description: fields[2] as String?,
      minQuantity: fields[3] as double,
      maxQuantity: fields[4] as double,
      order: fields[5] as double,
      onHand: fields[6] as double,
      sku: fields[7] as String?,
      isActive: fields[8] as String?,
      num: fields[9] as String?,
      isLot: fields[10] as bool?,
      isSerial: fields[11] as bool?,
      shortDescription: fields[12] as String?,
      imagePath: fields[13] as String?,
      category: fields[14] as String?,
      uom: fields[15] as String?,
      quantityUnit: fields[16] as String?,
      cost: fields[17] as String?,
      price: fields[18] as String?,
      createdDate: fields[19] as String?,
      modifiedDate: fields[20] as String?,
      quantity: fields[21] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, StockModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.minQuantity)
      ..writeByte(4)
      ..write(obj.maxQuantity)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.onHand)
      ..writeByte(7)
      ..write(obj.sku)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.num)
      ..writeByte(10)
      ..write(obj.isLot)
      ..writeByte(11)
      ..write(obj.isSerial)
      ..writeByte(12)
      ..write(obj.shortDescription)
      ..writeByte(13)
      ..write(obj.imagePath)
      ..writeByte(14)
      ..write(obj.category)
      ..writeByte(15)
      ..write(obj.uom)
      ..writeByte(16)
      ..write(obj.quantityUnit)
      ..writeByte(17)
      ..write(obj.cost)
      ..writeByte(18)
      ..write(obj.price)
      ..writeByte(19)
      ..write(obj.createdDate)
      ..writeByte(20)
      ..write(obj.modifiedDate)
      ..writeByte(21)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
