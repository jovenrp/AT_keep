import 'package:hive/hive.dart';

import '../../data/models/order_line_model.dart';

abstract class OrderLineRepository {
  Future<Box> openBox();
  List<OrderLineModel> getOrderLineList(Box box);
  Future<void> addOrderLine(Box box, OrderLineModel orderLineModel);
}
