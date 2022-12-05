import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

part 'order_line_model.g.dart';

@HiveType(typeId: 3)
class OrderLineModel {
  OrderLineModel({
    this.id,
    this.orderId,
    this.stockId,
    this.lineNum,
    this.quantity = 0,
    this.createdDate,
    this.modifiedDate,
    this.stockModel,
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

  StockModel? stockModel;

  void setModifiedDate(String modifiedDate) {
    this.modifiedDate = modifiedDate;
  }

  void setStock(StockModel stock) {
    stockModel = stock;
  }
}
