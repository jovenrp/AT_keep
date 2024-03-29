// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_line_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderLineModelAdapter extends TypeAdapter<OrderLineModel> {
  @override
  final int typeId = 3;

  @override
  OrderLineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderLineModel(
      id: fields[0] as String?,
      orderId: fields[1] as String?,
      stockId: fields[2] as String?,
      lineNum: fields[3] as String?,
      quantity: fields[4] as double?,
      originalQuantity: fields[7] as double?,
      createdDate: fields[5] as String?,
      modifiedDate: fields[6] as String?,
      status: fields[8] as String?,
      ordered: fields[9] as double?,
      isChecked: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderLineModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.stockId)
      ..writeByte(3)
      ..write(obj.lineNum)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.createdDate)
      ..writeByte(6)
      ..write(obj.modifiedDate)
      ..writeByte(7)
      ..write(obj.originalQuantity)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.ordered)
      ..writeByte(10)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
