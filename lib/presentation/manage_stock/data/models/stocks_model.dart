import 'package:hive/hive.dart';

part 'stocks_model.g.dart';

@HiveType(typeId: 0)
class StockModel {
  StockModel({
    this.id,
    this.name,
    this.description,
    this.minQuantity,
    this.maxQuantity,
    this.orderQuantity = 0,
    this.quantityOnHand = 0,
    this.sku,
    this.isActive = 'Y',
    this.num,
    this.isLot = false,
    this.isSerial = false,
    this.shortDescription,
    this.imagePath,
    this.category,
    this.uom,
    this.quantityUnit,
    this.cost,
    this.price,
    this.createdDate,
    this.modifiedDate,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  double? minQuantity;

  @HiveField(4)
  double? maxQuantity;

  @HiveField(5)
  double? orderQuantity;

  @HiveField(6)
  double? quantityOnHand;

  @HiveField(7)
  String? sku;

  @HiveField(8)
  String? isActive;

  @HiveField(9)
  String? num;

  @HiveField(10)
  bool? isLot;

  @HiveField(11)
  bool? isSerial;

  @HiveField(12)
  String? shortDescription;

  @HiveField(13)
  String? imagePath;

  @HiveField(14)
  String? category;

  @HiveField(15)
  String? uom;

  @HiveField(16)
  String? quantityUnit;

  @HiveField(17)
  String? cost;

  @HiveField(18)
  String? price;

  @HiveField(19)
  String? createdDate;

  @HiveField(20)
  String? modifiedDate;

  void setName(String name) {
    this.name = name;
  }

  void setDescription(String description) {
    this.description = description;
  }

  void setSku(String sku) {
    this.sku = sku;
  }

  void setMinQuantity(double quantity) {
    minQuantity = quantity;
  }

  void setMaxQuantity(double quantity) {
    maxQuantity = quantity;
  }

  void setQuantityOnHand(double quantity) {
    quantityOnHand = quantity;
  }

  void setOrderQuantity(double quantity) {
    orderQuantity = quantity;
  }

  void setNum(String num) {
    this.num = num;
  }
}
