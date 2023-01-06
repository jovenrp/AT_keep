import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:keep/presentation/landing/domain/repositories/landing_repository.dart';
import 'package:keep/presentation/profile/data/models/profile_model.dart';

import '../../../manage_stock/data/models/stocks_model.dart';
import '../../../order_history/data/models/order_line_model.dart';
import '../../../order_history/data/models/order_model.dart';

class LandingRepositoryImpl implements LandingRepository {
  LandingRepositoryImpl();

  String stocksBox = 'stocks_box';
  String profileBox = 'profile_box';
  String orderBox = 'order_box';
  String orderLineBox = 'order_line_box';

  @override
  Future<Box> openStocksBox() async {
    Box box = await Hive.openBox<StockModel>(stocksBox);
    return box;
  }

  @override
  Future<Box> openProfileBox() async {
    Box box = await Hive.openBox<ProfileModel>(profileBox);
    return box;
  }

  @override
  Future<Box> openOrderBox() async {
    Box box = await Hive.openBox<OrderModel>(orderBox);
    return box;
  }

  @override
  Future<Box> openOrderLineBox() async {
    Box box = await Hive.openBox<OrderLineModel>(orderLineBox);
    return box;
  }

  @override
  Future<Map<String, dynamic>> backupStocks(Box box) async {
    Map<String, dynamic> map = Hive.box<StockModel>(stocksBox)
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));

    return map;
  }

  @override
  Future<Map<String, dynamic>> backupProfile(Box box) async {
    Map<String, dynamic> map = Hive.box<ProfileModel>(profileBox)
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));

    return map;
  }

  @override
  Future<Map<String, dynamic>> backupOrder(Box box) async {
    Map<String, dynamic> map = Hive.box<OrderModel>(orderBox)
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));

    return map;
  }

  @override
  Future<Map<String, dynamic>> backupOrderLine(Box box) async {
    Map<String, dynamic> map = Hive.box<OrderLineModel>(orderLineBox)
        .toMap()
        .map((key, value) => MapEntry(key.toString(), value));

    return map;
  }

  @override
  Future<String?> restoreStocks(Box box) async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (file?.files.first.extension == 'json') {
      if (file != null) {
        File files = File(file.files.single.path.toString());
        String filename = file.files.single.name.toString().split('_').first;

        if (filename.toLowerCase() == 'stocks') {
          Hive.box<StockModel>(stocksBox).clear();
          Map<String, dynamic> map = jsonDecode(await files.readAsString());

          map.forEach((key, value) {
            StockModel product = StockModel.fromJson(value);
            Hive.box<StockModel>(stocksBox).put(product.id, product);
          });
        } else if (filename.toLowerCase() == 'profile') {
          Hive.box<ProfileModel>(profileBox).clear();
          Map<String, dynamic> map = jsonDecode(await files.readAsString());

          map.forEach((key, value) {
            ProfileModel profiles = ProfileModel.fromJson(value);
            Hive.box<ProfileModel>(profileBox).put(profiles.id, profiles);
          });
        } else if (filename.toLowerCase() == 'order') {
          Hive.box<OrderModel>(orderBox).clear();
          Map<String, dynamic> map = jsonDecode(await files.readAsString());

          map.forEach((key, value) {
            OrderModel orders = OrderModel.fromJson(value);
            Hive.box<OrderModel>(orderBox).put(orders.id, orders);
          });
        } else if (filename.toLowerCase() == 'orderline') {
          Hive.box<OrderLineModel>(orderLineBox).clear();
          Map<String, dynamic> map = jsonDecode(await files.readAsString());

          map.forEach((key, value) {
            OrderLineModel orderLines = OrderLineModel.fromJson(value);
            Hive.box<OrderLineModel>(orderLineBox)
                .put(orderLines.id, orderLines);
          });
        }
        return 'success';
      } else {
        //error
        return 'error';
      }
    } else {
      //error not a json file
      return 'incompatible';
    }
  }

  @override
  Future<String?> importCSV(Box box, String action) async {
    FilePickerResult? file = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (file?.files.first.extension == 'csv') {
      if (file != null) {
        File files = File(file.files.single.path.toString());
        String filename = file.files.single.name.toString().split('_').first;

        if (filename.toLowerCase() == 'stocks') {
          if (action == 'overwrite') {
            Hive.box<StockModel>(stocksBox).clear();
          }

          final csvFile = File(file.files.single.path.toString()).openRead();
          List<List<dynamic>> data = await csvFile
              .transform(utf8.decoder)
              .transform(
                const CsvToListConverter(),
              )
              .toList();

          List<StockModel> stocks = <StockModel>[];
          int index = 0;
          for (List<dynamic> item in data) {
            print(item);
            if (index > 0) {
              StockModel stock = StockModel(
                id: item[0].toString(),
                name: item[1].toString(),
                description: item[2].toString(),
                minQuantity: double.parse(item[3].toString()),
                maxQuantity: double.parse(item[4].toString()),
                order: double.parse(item[5].toString()),
                onHand: double.parse(item[6].toString()),
                sku: item[7].toString(),
                num: item[8].toString(),
              );
              stocks.add(stock);
              Hive.box<StockModel>(stocksBox).put(item[0].toString(), stock);
            }
            index++;
          }
        }
        return 'success csv';
      } else {
        //error
        return 'error csv';
      }
    } else {
      //error not a json file
      return 'incompatible';
    }
  }
}
