import 'package:hive/hive.dart';

import '../../data/models/order_model.dart';

abstract class OrderRepository {
  Future<Box> openBox();
  List<OrderModel> getOrderList(Box box);
  Future<void> addOrder(Box box, OrderModel orderModel);
}
