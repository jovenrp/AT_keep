import 'package:hive/hive.dart';

part 'stocks_model.g.dart';

@HiveType(typeId: 0)
class StockModel {
  StockModel({
    this.id,
    this.name,
    this.description,
    this.minQuantity = 0,
    this.maxQuantity = 0,
    this.order = 0,
    this.onHand = 0,
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
    this.quantity = 0,
    this.isOrdered = false,
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
  double? order;

  @HiveField(6)
  double? onHand;

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

  @HiveField(21)
  double? quantity;

  @HiveField(22)
  bool? isOrdered;

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

  void setonHand(double quantity) {
    onHand = quantity;
  }

  void setorder(double quantity) {
    order = quantity;
  }

  void setNum(String num) {
    this.num = num;
  }

  void setQuantity(double quantity) {
    this.quantity = quantity;
  }

  void setIsOrdered(bool isOrdered) {
    this.isOrdered = isOrdered;
  }

  void setIsActive(String isActive) {
    this.isActive = isActive;
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name.toString(),
        'description': description.toString(),
        'minQuantity': minQuantity.toString(),
        'maxQuantity': maxQuantity.toString(),
        'order': order.toString(),
        'onHand': onHand.toString(),
        'sku': sku.toString(),
        'isActive': isActive.toString(),
        'num': num.toString(),
        'isLot': isLot.toString(),
        'isSerial': isSerial.toString(),
        'shortDescription': shortDescription.toString(),
        'imagePath': imagePath.toString(),
        'category': category.toString(),
        'uom': uom.toString(),
        'quantityUnit': quantityUnit.toString(),
        'cost': cost.toString(),
        'price': price.toString(),
        'createdDate': createdDate.toString(),
        'modifiedDate': modifiedDate.toString(),
        'quantity': quantity.toString(),
        'isOrdered': isOrdered.toString(),
      };

  StockModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    minQuantity = double.parse(json['minQuantity'] ?? '0');
    maxQuantity = double.parse(json['maxQuantity'] ?? '0');
    order = double.parse(json['order'] ?? '0');
    onHand = double.parse(json['onHand'] ?? '0');
    sku = json['sku'];
    isActive = json['isActive'];
    num = json['num'];
    isLot = parseBool(json['isLot'] ?? 'false');
    isSerial = parseBool(json['isSerial'] ?? 'false');
    shortDescription = json['shortDescription'];
    imagePath = json['imagePath'];
    category = json['category'];
    uom = json['uom'];
    quantityUnit = json['quantityUnit'];
    cost = json['cost'];
    price = json['price'];
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
    quantity = double.parse(json['quantity'] ?? '0');
    isOrdered = parseBool(json['isOrdered'] ?? 'false');
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
