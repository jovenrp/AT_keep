import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

abstract class OrderRepository {
  Future<Box> openBox(String boxName);
  List<StockModel> getStockList(Box box);
  Future<void> addStock(Box box, StockModel stockModel);
  Future<void> updateStock(Box box, int index, StockModel stockModel);
  Future<void> deleteStock(Box box, StockModel stockModel, int index);
  Future<void> clearStock(Box box);
  Future<void> backupDatabase(Box box, String? path);
  Future<void> restoreDatabase(Box box, String? path);
}
