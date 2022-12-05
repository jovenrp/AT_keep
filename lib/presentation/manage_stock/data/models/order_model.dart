import 'package:hive/hive.dart';

import 'order_line_model.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class OrderModel {
  OrderModel({
    this.id,
    this.num,
    this.name,
    this.source,
    this.status,
    this.createdDate,
    this.modifiedDate,
    this.orderLineList,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? num;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String? source;

  @HiveField(4)
  String? status;

  @HiveField(5)
  String? createdDate;

  @HiveField(6)
  String? modifiedDate;

  List<OrderLineModel>? orderLineList;

  void setName(String name) {
    this.name = name;
  }

  void setStatus(String status) {
    this.status = status;
  }

  void setSource(String source) {
    this.source = source;
  }

  void setOrderLineList(List<OrderLineModel> orderLines) {
    orderLineList = orderLines;
  }
}
