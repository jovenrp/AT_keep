import 'package:hive/hive.dart';

import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import 'order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl();

  String orderBoxName = 'order_box';
  String orderLinBoxName = 'order_line_box';

  @override
  Future<Box> openBox(String boxName) async {
    Box box = await Hive.openBox<StockModel>(boxName);
    return box;
  }

  @override
  Future<void> addStock(Box box, StockModel stockModel) {
    // TODO: implement addStock
    throw UnimplementedError();
  }

  @override
  Future<void> backupDatabase(Box box, String? path) {
    // TODO: implement backupDatabase
    throw UnimplementedError();
  }

  @override
  Future<void> clearStock(Box box) {
    // TODO: implement clearStock
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStock(Box box, StockModel stockModel, int index) {
    // TODO: implement deleteStock
    throw UnimplementedError();
  }

  @override
  List<StockModel> getStockList(Box box) {
    // TODO: implement getStockList
    throw UnimplementedError();
  }

  @override
  Future<void> restoreDatabase(Box box, String? path) {
    // TODO: implement restoreDatabase
    throw UnimplementedError();
  }

  @override
  Future<void> updateStock(Box box, int index, StockModel stockModel) {
    // TODO: implement updateStock
    throw UnimplementedError();
  }
}
