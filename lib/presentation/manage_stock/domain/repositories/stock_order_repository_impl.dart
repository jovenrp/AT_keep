import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';
import 'package:keep/presentation/manage_stock/data/services/manage_stock_api_service.dart';

import 'stock_order_repository.dart';

class StockOrderRepositoryImpl implements StockOrderRepository {
  StockOrderRepositoryImpl(this._apiService);

  final ManageStockApi _apiService;

  String boxName = 'stocks_box';

  @override
  Future<Box> openBox() async {
    Box box = await Hive.openBox<StockModel>(boxName);
    return box;
  }

  @override
  List<StockModel> getStockList(Box box) {
    return box.values.toList() as List<StockModel>;
  }

  @override
  Future<void> addStock(Box box, StockModel stockModel) async {
    await box.put(stockModel.id, stockModel);
  }

  @override
  Future<void> updateStock(Box box, StockModel stockModel) async {
    await box.put(stockModel.id, stockModel);
  }

  @override
  Future<void> clearStock(Box box) async {
    await box.clear();
  }

  @override
  Future<void> deleteStock(Box box, StockModel stockModel, int index) async {
    await box.delete(stockModel.id);
    //await box.clear();
  }

  @override
  Future<void> backupDatabase(Box box, String? path) async {
    /*final box = await Hive.openBox(boxName);
    final boxPath = box.path;
    await box.close();

    try {
      File(boxPath ?? '').copy(path ?? '');
    } finally {
      await Hive.openBox(boxName);
    }*/
    //await box.clear();
  }

  @override
  Future<void> restoreDatabase(Box box, String? path) async {
    /*final box = await Hive.openBox(boxName);
    final boxPath = box.path;
    await box.close();

    try {
      File(path ?? '').copy(boxPath ?? '');
    } finally {
      await Hive.openBox(boxName);
    }*/
    //await box.clear();
  }

  @override
  Future<String> getUpc(String? barcode) async {
    try {
      dynamic token = await _apiService.getUpc(barcode ?? '');

      print(token);
      return '';
    } catch (e) {
      print('UPC Error ${e.toString()}');
      return '';
    }
  }
}
