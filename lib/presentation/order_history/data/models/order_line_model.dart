import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

part 'order_line_model.g.dart';

@HiveType(typeId: 3)
class OrderLineModel {
  OrderLineModel(
      {this.id,
      this.orderId,
      this.stockId,
      this.lineNum,
      this.quantity = 0,
      this.originalQuantity = 0,
      this.createdDate,
      this.modifiedDate,
      this.stockModel,
      this.status,
      this.ordered = 0,
      this.isChecked = false});

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? orderId;

  @HiveField(2)
  String? stockId;

  @HiveField(3)
  String? lineNum;

  @HiveField(4)
  double? quantity;

  @HiveField(5)
  String? createdDate;

  @HiveField(6)
  String? modifiedDate;

  @HiveField(7)
  double? originalQuantity;

  StockModel? stockModel;

  @HiveField(8)
  String? status;

  @HiveField(9)
  double? ordered;

  @HiveField(10)
  bool? isChecked;

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'orderId': orderId.toString(),
        'stockId': stockId.toString(),
        'lineNum': lineNum.toString(),
        'quantity': quantity.toString(),
        'createdDate': createdDate.toString(),
        'modifiedDate': modifiedDate.toString(),
        'originalQuantity': originalQuantity.toString(),
        'status': status.toString(),
        'ordered': ordered.toString(),
        'isChecked': isChecked.toString(),
      };

  OrderLineModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    stockId = json['stockId'];
    lineNum = json['lineNum'];
    quantity = double.parse(json['quantity']);
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    originalQuantity = double.parse(json['originalQuantity']);
    status = json['status'];
    ordered = double.parse(json['ordered']);
    isChecked = parseBool(json['isChecked'] ?? 'false');
  }

  void setModifiedDate(String modifiedDate) {
    this.modifiedDate = modifiedDate;
  }

  void setStock(StockModel stock) {
    stockModel = stock;
  }

  void setQuantity(double quantity) {
    this.quantity = quantity;
  }

  void setOrdered(double ordered) {
    this.ordered = ordered;
  }

  void setOriginalQuantity(double quantity) {
    originalQuantity = quantity;
  }

  void setStatus(String status) {
    this.status = status;
  }

  void setIsChecked(bool isChecked) {
    this.isChecked = isChecked;
  }

  bool parseBool(String value) {
    if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    }

    throw '"$this" can not be parsed to boolean.';
  }
}
