import 'package:hive/hive.dart';
import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

abstract class BaseStorageRepository {
  Future<Box> openBox();
  List<StockModel> getStockList(Box box);
  Future<void> addStock(Box box, StockModel stockModel);
  Future<void> updateStock(Box box, int index, StockModel stockModel);
  Future<void> deleteStock(Box box, StockModel stockModel, int index);
}
