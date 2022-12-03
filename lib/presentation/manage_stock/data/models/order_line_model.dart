import 'package:hive/hive.dart';

part 'order_line_model.g.dart';

@HiveType(typeId: 3)
class OrderModel {
  OrderModel({
    this.id,
    this.orderId,
    this.stockId,
    this.lineNum,
    this.quantity = 0,
    this.createdDate,
    this.modifiedDate,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? orderId;

  @HiveField(2)
  String? stockId;

  @HiveField(3)
  String? lineNum;

  @HiveField(4)
  double quantity;

  @HiveField(5)
  String? createdDate;

  @HiveField(6)
  String? modifiedDate;

  void setModifiedDate(String modifiedDate) {
    this.modifiedDate = modifiedDate;
  }
}
