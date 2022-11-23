import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:keep/presentation/manage_stock/data/models/stocks_model.dart';

import 'base_storage_repository.dart';

class BaseStorageRepositoryImpl implements BaseStorageRepository {
  BaseStorageRepositoryImpl();

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
  Future<void> updateStock(Box box, int index, StockModel stockModel) async {
    await box.putAt(index, stockModel);
  }

  @override
  Future<void> deleteStock(Box box, StockModel stockModel, int index) async {
    await box.deleteAt(index);
    //await box.clear();
  }
}
