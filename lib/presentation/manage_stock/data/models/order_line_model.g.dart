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
      quantity: fields[4] as double,
      createdDate: fields[5] as String?,
      modifiedDate: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderLineModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.modifiedDate);
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
