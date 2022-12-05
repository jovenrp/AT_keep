import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/order_line_model.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import '../../../manage_stock/data/models/order_model.dart';

abstract class OrderRepository {
  Future<Box> openBox();
  List<OrderModel> getOrderList(Box box);
  Future<void> addOrder(Box box, OrderModel orderModel);
}
