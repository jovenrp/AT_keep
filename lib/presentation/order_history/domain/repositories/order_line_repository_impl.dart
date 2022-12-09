import 'package:hive/hive.dart';
import '../../data/models/order_line_model.dart';
import 'order_line_repository.dart';

class OrderLineRepositoryImpl implements OrderLineRepository {
  OrderLineRepositoryImpl();

  String boxName = 'order_line_box';

  @override
  Future<Box> openBox() async {
    Box box = await Hive.openBox<OrderLineModel>(boxName);
    return box;
  }

  @override
  List<OrderLineModel> getOrderLineList(Box box) {
    return box.values.toList() as List<OrderLineModel>;
  }

  @override
  Future<void> addOrderLine(Box box, OrderLineModel orderModel) async {
    await box.put(orderModel.id, orderModel);
  }
}
