import 'package:hive/hive.dart';
import '../../data/models/order_model.dart';
import 'order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl();

  String boxName = 'order_box';

  @override
  Future<Box> openBox() async {
    Box box = await Hive.openBox<OrderModel>(boxName);
    return box;
  }

  @override
  List<OrderModel> getOrderList(Box box) {
    return box.values.toList() as List<OrderModel>;
  }

  @override
  Future<void> addOrder(Box box, OrderModel orderModel) async {
    await box.put(orderModel.id, orderModel);
  }
}
