import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/order_line_model.dart';

abstract class OrderLineRepository {
  Future<Box> openBox();
  List<OrderLineModel> getOrderLineList(Box box);
  Future<void> addOrderLine(Box box, OrderLineModel orderLineModel);
}
