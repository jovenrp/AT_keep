import 'package:hive/hive.dart';

import 'order_line_model.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class OrderModel {
  OrderModel(
      {this.id,
      this.num,
      this.name,
      this.source,
      this.status,
      this.createdDate,
      this.modifiedDate,
      this.orderLineList,
      this.longitude = 0,
      this.latitude = 0,
      this.accuracy = 0});

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

  @HiveField(7)
  double? longitude;

  @HiveField(8)
  double? latitude;

  @HiveField(9)
  double? accuracy;

  List<OrderLineModel>? orderLineList;

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'num': num.toString(),
        'name': name.toString(),
        'source': source.toString(),
        'status': status.toString(),
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'accuracy': accuracy.toString(),
        'createdDate': createdDate.toString(),
        'modifiedDate': modifiedDate.toString(),
      };

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    num = json['num'];
    name = json['name'];
    source = json['source'];
    status = json['status'];
    longitude = double.parse(json['longitude'] ?? '0');
    latitude = double.parse(json['latitude'] ?? '0');
    accuracy = double.parse(json['accuracy'] ?? '0');
    createdDate = json['createdDate'];
    modifiedDate = json['modifiedDate'];
  }

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

  void setLongitude(double longitude) {
    this.longitude = longitude;
  }

  void setLatitude(double latitude) {
    this.latitude = latitude;
  }

  void setAccuracy(double accuracy) {
    this.accuracy = accuracy;
  }
}
